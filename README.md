# FlightController

The OpenSpace FlightController allows you to pilot OpenSpace from your phone.

## Requirements
- An iPhone >= 6s with Force Touch capabilities
- iOS >= 11
- Haptic feedback enabled
- A private WiFi network that is configured to allow traffic to the machine that OpenSpace runs on
- OpenSpace download or compiled with the server module enabled

## Connecting
Enter the IPv4 address or domain name of the OpenSpace master node and hit connect. Port is not required, and currently only the default of 8001 is supported.

## Controls
FlightController is designed minimize the need to look at the screen. It registers gestures through the accelerometer, touchscreen, and Force Touch capabilities of the iPhone, and offers haptic feedback to notify the user of events.

The basic controls are on-screen joysticks. There are reference markers on the screen, but they do not need to be targeted: simply touching anywhere on the screen will set the initial position to that location and register whether it was a left or right stick. The only limits to tracking a touch are the edges of the screen—a continuous touch will be registered from it's starting point to anywhere else on the screen and the magnitude will be adjusted accordingly.

To interact with the accelerometer, deep press until haptic feedback is felt. The accelerometer will continue registering events as long as you maintain contact with the screen. To disable the accelerometer, simply release all touches. Note (in progress): deep pressing the left, right, or both stick will activate different control schemes.

The FlightController can operate in both standard (landscape) and one-handed (profile) orientations. The control scheme automatically adjusts based on orientation of the device.

### Landscape Mode
Landscape mode is for precision flying. Camera Friction is enabled by default, so the camera will come to rest if there is no input. The default interaction mappings are:

#### Joysticks
- Right Stick X: Orbit around the focus object horizontally
- Right Stick Y: Orbit around the focus object vertically
- Left Stick X: Rotate the focus object/view
- Left Stick Y: Zoom

#### Accelerometer
- Deep Press Right Stick: No default
- Deep Press Left Stick: Activates Pitch
	- Pitch: Rotates camera around its X-Axis
- Deep Press Both Sticks: No default

### Portrait Mode
Portrait mode is for more casual, exploratory flight. It is envisioned more for use in terrain flyovers rather than orbital and space flight. Camera Friction is disabled by default. This simulates a cruise-control-like interaction: use the stick to add or remove acceleration and when you release, it will remain at that speed. The default mappings are:

#### Joystick
- Stick X: Orbit around the focus object horizontally 
- Stick Y: Orbit around the focus object vertically 

#### Accelerometer
- Deep Press: Activates Pitch & Roll
	- Pitch: Zoom
	- Roll: Rotate the focus object/view

## Todo
- Run/send Lua scripts
- Configure the axes from configuration files
- Siri integration for commands
