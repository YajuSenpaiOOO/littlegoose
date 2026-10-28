shader_type spatial;
render_mode unshaded, shadows_disabled;
// Sprite metadata supplies the existing terrain projection. The subdivided
// child mesh draws the actual sword instead of Sprite3D's rigid four corners.
void fragment(){ discard; }
