#include <godot_cpp/godot.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/physics_direct_space_state3d.hpp>
#include <godot_cpp/classes/physics_ray_query_parameters3d.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <algorithm>
#include <cmath>
#include <vector>

using namespace godot;

// Only the hot projectile loop lives here. Scene lifecycle, damage, feedback,
// native Jolt collision, pooling and fragment generation remain owned by GDScript.
class NativeCombat113 : public RefCounted {
 GDCLASS(NativeCombat113, RefCounted)
 struct Target { Node3D *node; Vector3 at; RID rid; };
 std::vector<Target> targets;
 const StringName node_key{"node"}, at_key{"at"}, previous_key{"previous"};
 const StringName velocity_key{"velocity"}, life_key{"life"}, grace_key{"spawn_grace111"};
 const StringName age_key{"steer_age111"}, target_key{"target110"}, until_key{"target_until110"};
 const StringName hits_key{"hit_rids"}, ignores_key{"ignore_rids110"};
 const StringName stream_key{"stream110"}, depth_key{"split_depth110"}, trail_key{"trail_distance"};
 const StringName dead_key{"dead"}, charged_key{"charged"}, piercing_key{"piercing110"};

 void steer(Dictionary &shot, const Vector3 &at, int level, double clock, double delta, double ppm) {
  const double age = double(shot.get(age_key, 0.0)) + delta;
  if (age < 1.0 / 30.0 - .00001) { shot[age_key] = age; return; }
  shot[age_key] = 0.0;
  delta = age;
  Vector3 velocity = shot[velocity_key];
  Vector2 forward(velocity.x, velocity.z);
  const double speed_squared = forward.length_squared();
  if (speed_squared < .0001) return;
  Object *saved = shot.get(target_key, Variant());
  Target *chosen = nullptr;
  for (Target &entry : targets) {
   if (entry.node == saved && !bool(entry.node->get(dead_key))) { chosen = &entry; break; }
  }
  if (saved && !chosen && bool(saved->get(dead_key))) shot[until_key] = 0.0;
  const double until = shot.get(until_key, 0.0);
  if (!chosen && clock < until) return;
  if (clock >= until) {
   chosen = nullptr;
   double closest = std::pow(240.0 / ppm, 2.0);
   const double cone = std::cos(level == 1 ? 1.4 : 1.9);
   const double speed = std::sqrt(speed_squared);
   const Array hits = shot[hits_key], ignores = shot[ignores_key];
   for (Target &entry : targets) {
    if (bool(entry.node->get(dead_key)) || hits.has(entry.rid) || ignores.has(entry.rid)) continue;
    const Vector2 toward(entry.at.x - at.x, entry.at.z - at.z);
    const double distance = toward.length_squared();
    if (distance < closest && forward.dot(toward) > cone * speed * std::sqrt(distance)) {
     chosen = &entry; closest = distance;
    }
   }
   shot[target_key] = chosen ? Variant(chosen->node) : Variant();
   shot[until_key] = clock + .08;
  }
  if (!chosen) return;
  const Vector3 desired = (chosen->at + Vector3(0, .65, 0) - at).normalized();
  const double rate = level == 1 ? 2.5 : 4.0;
  const double turn = std::clamp(double(forward.angle_to(Vector2(desired.x, desired.z))), -rate * delta, rate * delta);
  const Vector2 flat = forward.normalized().rotated(real_t(turn));
  const double speed = velocity.length();
  const double t = std::min(1.0, rate * delta);
  const double vy = velocity.y + (desired.y * speed - velocity.y) * t;
  const double horizontal = std::sqrt(std::max(0.0, speed * speed - vy * vy));
  shot[velocity_key] = Vector3(real_t(flat.x * horizontal), real_t(vy), real_t(flat.y * horizontal));
 }

protected:
 static void _bind_methods() {
  ClassDB::bind_method(D_METHOD("step", "battle", "delta", "ppm"), &NativeCombat113::step);
 }
public:
 void step(Object *battle, double delta, double ppm) {
  if (!battle) return;
  Array shots = battle->get("shots");
  if (shots.is_empty()) return;
  Object *buffs = battle->get("buffs");
  const int tracking = int64_t(buffs->call("level", "eye_exercise"));
  const double clock = battle->get("combat_clock33");
  targets.clear();
  if (tracking) {
   const Array enemies = battle->get("enemies");
   for (int64_t i = 0; i < enemies.size(); ++i) {
    Node3D *enemy = Object::cast_to<Node3D>((Object *)enemies[i]);
    if (!enemy || bool(enemy->get(dead_key))) continue;
    Object *area = enemy->get("hit_area");
    targets.push_back({enemy, enemy->get_position(), RID(area->call("get_rid"))});
   }
  }
  PhysicsDirectSpaceState3D *space = Object::cast_to<PhysicsDirectSpaceState3D>((Object *)battle->get("space110"));
  Ref<PhysicsRayQueryParameters3D> query = battle->get("query110");
  Object *hero = battle->get("hero");
  Object *pool = battle->get("pool110");
  TypedArray<RID> excluded; excluded.push_back(hero->call("get_rid"));
  bool simple = false;
  battle->set("simple_trace113", false);
  for (int64_t i = shots.size() - 1; i >= 0; --i) {
   if (i >= shots.size()) continue;
   Dictionary shot = shots[i];
   Object *state = shot[node_key];
   Vector3 start = state->get(at_key);
   const double grace = shot.get(grace_key, 0.0);
   double life = shot[life_key];
   if (grace > 0.0) {
    shot[grace_key] = std::max(0.0, grace - delta);
    const Vector3 velocity = shot[velocity_key];
    state->set(previous_key, start); state->set(at_key, start + velocity * real_t(delta));
    life -= delta; shot[life_key] = life;
    if (life <= 0.0) { pool->call("retire", shot); shots.remove_at(i); }
    continue;
   }
   if (tracking) steer(shot, start, tracking, clock, delta, ppm);
   const Vector3 velocity = shot[velocity_key];
   const Vector3 end = start + velocity * real_t(delta);
   Dictionary hit;
   if (!start.is_finite() || !end.is_finite()) {
    shot[life_key] = 0.0; life = 0.0;
   } else if (bool(shot.get(piercing_key, false)) || bool(shot.get(charged_key, false)) || !Array(shot[ignores_key]).is_empty() || bool(battle->get("use_grid111"))) {
    simple = false; hit = battle->call("_trace_shot", shot, start, end);
   } else {
    if (!simple) { query->set_exclude(excluded); simple = true; }
    query->set_from(start); query->set_to(end);
    hit = space->intersect_ray(query);
   }
   life = double(shot[life_key]) - delta; shot[life_key] = life;
   if (!bool(shot.get(stream_key, false)) && int64_t(shot.get(depth_key, 0)) == 0) {
    const double distance = double(shot[trail_key]) + start.distance_to(end);
    if (distance >= 4.5 / ppm) {
     battle->call("emit_trail", end, velocity.normalized()); shot[trail_key] = std::fmod(distance, 4.5 / ppm);
    } else shot[trail_key] = distance;
   }
   if (!hit.is_empty()) battle->call("_apply_shot_hit", shot, hit);
   else if (life <= 0.0) battle->call("_shot_expired", shot);
   if (!hit.is_empty() || life <= 0.0) {
    if (i < shots.size() && Dictionary(shots[i]) == shot) { pool->call("retire", shot); shots.remove_at(i); }
   } else {
    state->set(previous_key, start); state->set(at_key, end);
   }
  }
  battle->set("simple_trace113", false);
 }
};

static void initialize_combat113(ModuleInitializationLevel level) {
 if (level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
 // Explicit registration also supports Clang's deferred initialization of
 // unused inline engine-class registration helpers in godot-cpp v10.
 internal::EngineClassRegistration<Object>::callback();
 internal::EngineClassRegistration<RefCounted>::callback();
 internal::EngineClassRegistration<Node>::callback();
 internal::EngineClassRegistration<Node3D>::callback();
 internal::EngineClassRegistration<PhysicsDirectSpaceState3D>::callback();
 internal::EngineClassRegistration<PhysicsRayQueryParameters3D>::callback();
 GDREGISTER_CLASS(NativeCombat113);
}
extern "C" GDExtensionBool GDE_EXPORT combat113_library_init(GDExtensionInterfaceGetProcAddress address, GDExtensionClassLibraryPtr library, GDExtensionInitialization *initialization) {
 GDExtensionBinding::InitObject init(address, library, initialization);
 init.register_initializer(initialize_combat113);init.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
 return init.init();
}
