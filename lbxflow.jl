ccall(:jl_exit_on_sigint, Void, (Cint,), 0); # Allows Ctrl+C to be caught
const LBX_VERSION = v"0.2.1";
const root = dirname(@__FILE__);

println();
println(readall(abspath(joinpath(root, "banner.txt"))));
println("version:  $LBX_VERSION");
println();

# load dependencies
require(abspath(joinpath(root, "inc", "api.jl")));
require("argparse");
using ArgParse;

s = ArgParseSettings();
@add_arg_table s begin
  "--file", "-f"
    help = "path to input file"
    arg_type = String
  "--dir", "-d"
    help = "directory with input file(s)"
    arg_type = String
  "--recursive", "-r"
    help = "recursively search directories for input file(s)"
    action = :store_true
  "--ext", "-x"
    help = "file extension of input file(s) (for directory search)"
    default = "yaml"
  "--verbose", "-v"
    help = "print extra information about execution status"
    action = :store_true
  "--clean", "-c"
    help = "clean out `datadir` defined in input file(s)"
    action = :store_true
  "--resume", "-R"
    help = "search for backup files and use if applicable"
    action = :store_true
  "--noexe", "-X"
    help = "do not execute input file(s)"
    action = :store_true
  "--log"
    help = "create a logfile"
    action = :store_true
  "--debug"
    help = "turns on debugging mode"
    action = :store_true
end

pa = parse_args(s);

# run input file
if pa["file"] != nothing
  parse_and_run(pa["file"], pa);
end

# recursively search directory for input files
function recursively_search_for_input_files(dir::String, ext::String)
  files = Array(ASCIIString, 0);
  function recursively_add_input_files!(files::Array{ASCIIString}, dir::String, ext::String)
    for f in readdir(dir)
      if isdir(joinpath(dir, f)); recursively_add_input_files!(files, joinpath(dir, f), ext); end
      if isfile(joinpath(dir, f)) && endswith(f, ext); push!(files, joinpath(dir, f)); end
    end
  end

  recursively_add_input_files!(files, dir, ext);
  return files;
end

# run input files from directory in parallel
if pa["dir"] != nothing

  if pa["recursive"] != nothing
    files = recursively_search_for_input_files(pa["dir"], pa["ext"]);
  else
    files = filter((x)->endswith(".$(pa["ext"])"), readdir(pa["dir"]));
  end
  
  for file in files
    parse_and_run(file, pa);
  end

end
