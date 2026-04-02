**HLVehicles**

HLVehicles provides a component-based approach to vehicles in Godot. Things like the engine, 
transmission, axles, wheels, and other things that make a vehicles are represented in the scene tree
by individual components.

The demo scene uses other MIT add-ons and CCO/CC-By 3.0 assets for the purpose of demonstrating usage of this add-on.

Current features:
* Independent suspension
* Power at the wheels
* Limited slip differentials
* Power based upon gear ratios
* Support for Terrain3D, such as sliding on ice textures (and the ability to implement custom terrain handlers)

Things notably not included (yet at least):
* Manual transmission - all transmissions in HLVehicles is more of a lookup table to
find power/RPMs based on speed and not the other way around. A manual transmission is
on the roadmap, but may be a ways off.

Example scene tree for a vehicle:

<img width="393" height="497" alt="image" src="https://github.com/user-attachments/assets/add6cc27-5685-425e-a192-8cb536191372" />

Example vehicle made with components showing independent suspension and axle staying inline with wheels:

<img width="474" height="348" alt="image" src="https://github.com/user-attachments/assets/195e4b22-bcb7-4a3e-bf3b-524eae3dd715" />

This repo also includes a material shader add-on we're using in one of our games. It's included here under MIT license as well.

The shader includes two versions, one we call the Universal Material Shader and a limited version just called Blended and Projected Matererial.

Features of the shader include:

* Primary texture (triplanar or standard UV map)
* Secondary texture blended into primary (i.e. using two low res textures at different scales if something needs to look good far away and reallllly up close)
* Projected texture (applies a texture based on angle and mask, i.e. snow on top of a boulder)
* Wind (noise, horizontal sway, and horizontal sway by using the RGB channels of vertex paint)

<img width="397" height="464" alt="image" src="https://github.com/user-attachments/assets/734de226-876f-4b6b-bf67-028c3572761b" />

Example of wind:

![20260402-0254-34 3340752](https://github.com/user-attachments/assets/93568eb1-77ea-4ab0-8801-6a8552db4b05)

Example of projected texture:

![20260402-0312-35 0043457](https://github.com/user-attachments/assets/554f6827-f318-41d9-a32b-ea56575f957f)

