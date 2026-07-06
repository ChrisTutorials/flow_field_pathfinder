#!/usr/bin/env python
import os
import sys

godot_cpp_path = os.environ.get("GODOT_CPP_PATH", "godot-cpp")
env = SConscript(os.path.join(godot_cpp_path, "SConstruct"))

env.Append(CPPPATH=["cpp/src/"])
sources = Glob("cpp/src/*.cpp")

library_name = "libflow_field_pathfinder{}{}".format(
    env["suffix"], env["SHLIBSUFFIX"])

library = env.SharedLibrary(
    target="addons/flow_field_pathfinder/bin/{}".format(library_name),
    source=sources,
    SHLIBSUFFIX=env["SHLIBSUFFIX"])

env.NoCache(library)
Default(library)
