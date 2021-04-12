import argparse
import subprocess
import defines
import helpers
import sys
import shutil
import time
import re 

OUT_FILE_PATH = defines.TMP_DIR + "/circuit.out"
VCD_FILE_PATH = defines.TMP_DIR + "/circuit.vcd"

VERILATOR = "verilator"

GCC = "gcc"
CLANG = "clang"

GCC_XX = "g++"
CLANG_XX = "clang++"

ROOT_INFO_STR = "VERILATOR_ROOT"
LOG_PATH = defines.TMP_DIR + "/simulation.log"


def parse_arguments():
    parser = argparse.ArgumentParser(description="Trace", fromfile_prefix_chars="@")

    parser.add_argument("-t", "--testbench", dest="tb_file_path",
                        required=True, type=helpers.ap_check_file_exists,
                        help="Path of testbench for the Verilog source file")
    parser.add_argument("-n", "--netlist", dest="netlist_file_path",
                        required=True, type=helpers.ap_check_file_exists,
                        help="Path of Verilog netlist generated by yosys")
    parser.add_argument("-b", "--skip-compile-netlist", dest="skip_compile_netlist",
                        required=False, default=False, action="store_true",
                        help="Use cached object files from a previous Verilator run (execute steps 3 and 4 but not 1 and 2)  (default: %(default)s)")
    parser.add_argument("-c", "--c-compiler", dest="c_compiler",
                        required=False, default=None, choices=[CLANG, GCC],
                        help="C compiler used by Verilator")
    parser.add_argument("-o", "--output-bin", dest="output_bin_path",
                        required=False, default=None)
 
    args, _ = parser.parse_known_args()
    
    if args.c_compiler is None:
        compilers = [CLANG, GCC]
        for cxx in compilers:
            bin_ = shutil.which(cxx)
            if bin_ is not None: 
                args.c_compiler = cxx
                break
    if args.c_compiler is None:
        print("ERROR: No compatible compiler found.")
        sys.exit(2)
    
    if args.c_compiler == CLANG:
        args.cxx_compiler = CLANG_XX
    elif args.c_compiler == GCC:
        args.cxx_compiler = GCC_XX
    
    assert(args.netlist_file_path.endswith(".v"))
    return args


def run_with_log(command):
    proc = subprocess.Popen(command, encoding="utf-8",
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate()
    with open(LOG_PATH, "a+") as log:
        log.write(stdout + stderr)
    return proc.returncode, stdout, stderr


def check_run(command, message):
    ret, out, err = run_with_log(command)
    if ret != 0 or "error" in (out + err).lower():
        print(out)
        print(err)
        print(message)
        sys.exit(1)


def get_verilator_include_path():
    info = subprocess.check_output([VERILATOR, "-V"], encoding="ascii")
    for info_line in info.split("\n"):
        info_line = info_line.split()
        if len(info_line) == 0: continue
        if info_line[0] != ROOT_INFO_STR: continue
        return info_line[2] + "/include"
    print("ERROR: Could not find Verilator root directory.")
    sys.exit(3)


def trace_verilator(args):
    obj_dir_path = defines.TMP_DIR + "/obj_dir"
    
    # tmp/circuit.v -> circuit
    raw_netlist_file_name = re.sub(r"(.*\/)", "", args.netlist_file_path).replace(".v", "")

    # Find path of verilator include files
    verilator_include_path = get_verilator_include_path()

    if not(args.skip_compile_netlist):
        print("1: Running verilator on given netlist")
        
        verilator_cmd = [VERILATOR, "--trace", "--trace-underscore", "--compiler", args.c_compiler, "-Wno-UNOPTFLAT", "-Wno-LITENDIAN", "-cc", args.netlist_file_path]

        check_run(verilator_cmd, "ERROR: Running verilator failed.")

        # Move the object directory into tmp
        shutil.rmtree(obj_dir_path, True)
        shutil.move("obj_dir", obj_dir_path)

        print("2: Compiling verilated netlist library")
        if args.c_compiler == CLANG:
            make_cmd = ["make", "-j", "2", "CXX=%s" % args.cxx_compiler, "-C", obj_dir_path, "-f", "V" + raw_netlist_file_name + ".mk"]
        else:
            make_cmd = ["make", "-j", "2", "-C", obj_dir_path, "-f", "V" + raw_netlist_file_name + ".mk"]
        check_run(make_cmd, "ERROR: Making verilated library failed.")


    # Compile binary and run it
    include_paths = [obj_dir_path, defines.TEMPLATE_DIR, verilator_include_path]
    include_paths = ["-I" + _ for _ in include_paths]
    cflags = ["-Wall", "-fno-diagnostics-color"]
    simulation_sources = [
        args.tb_file_path, 
        "%s/V%s__ALL.a" % (obj_dir_path, raw_netlist_file_name),
        verilator_include_path + "/verilated.cpp",
        verilator_include_path + "/verilated_vcd_c.cpp"]
    

    output_bin_path = defines.TMP_DIR + "/" + raw_netlist_file_name if args.output_bin_path == None else args.output_bin_path

    compile_cmd = [[args.cxx_compiler], cflags, include_paths,
                   simulation_sources, ["-o", output_bin_path]]    
    
    compile_cmd = sum(compile_cmd, [])  # Flatten compile command

    print("3: Compiling provided verilator testbench")
    check_run(compile_cmd, "ERROR: Compiling testbench failed.")

    print("4: Simulating circuit and generating VCD")
    check_run([output_bin_path], "Simulating circuit failed.")


def main():
    args = parse_arguments()
    try:
        f = open(LOG_PATH, "w")
        f.close()
    except:
        print("ERROR: Could not open log: %s" % LOG_PATH)
        sys.exit(4)

    
    trace_verilator(args)

if __name__ == "__main__": 
    main()