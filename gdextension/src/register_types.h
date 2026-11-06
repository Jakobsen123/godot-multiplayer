#ifndef GMP_REGISTER_TYPES_H
#define GMP_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_gmp_module(ModuleInitializationLevel p_level);
void uninitialize_gmp_module(ModuleInitializationLevel p_level);

#endif
