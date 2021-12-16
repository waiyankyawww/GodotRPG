extends AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "_on_animation_finished") # connecting signal in code
	frame = 0
	play("Animate")

#connect with the signal and destroyed when the animation is finished
func _on_animation_finished():
	queue_free()
