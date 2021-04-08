
/*
themidibus needs to be installed from Processing
In order to animate the gifs, an external library needs to be installed manually: https://github.com/extrapixel/gif-animation/tree/3.0
*/

import gifAnimation.*;
import themidibus.*;
import javax.sound.midi.MidiMessage;

// Hexadecimal color used to paint objects
color backHill_color = #42687C;
color foreHill_color = #84A5B8;
color ground_color =   #E5E5E5;
color sky_color =      #B3DAF1;
color white =          #FFFFFF;

// Cloud properties
float[] clouds = { -50, 400, 900};    // Initial positions
float speed_clouds = 0.3;

// Initial position of background hills
float[] hills = { -300, 300, 900 };

// Initial position of foreground hills
float[] fHills = { -300, 0, 300, 600, 900, 1200 };

// Snow mound properties
float snow = 1350;

// Used to start and stop movement of snow mound
boolean snow_lock = true;


// Initial position for the fox
float fox_x = -300;
float fox_y = 685;

// As sprites have different sizes, an offset is applied to have them line up
float fox_y_offset = 0;

// Movement properties of the fox
float speed_fox = 0;

// Gif object used to anime .gif in the screen
Gif fox_gif;

// Object used to read input from SuperCollider
MidiBus midi_bus;


public void setup() {
  size(1200, 900);
  noStroke();
  frameRate(120);
  
  // Start fox in idle animation
  fox_gif = new Gif(this, "fox-idle.gif");
  
  // MIDI inputs received in channel 0 and output from channel 0
  midi_bus = new MidiBus(this, 0, 1);
}

void draw() {
  
  // = = = = = = = = = = = =
  // =   DRAWING STUFF     =
  // = = = = = = = = = = = =
  
  // For background images, they loop. Once they reach a certain x value, they begin in a default position, looping them infinitely
  
  background(sky_color);

  // CLOUDS - - -
  fill(white);
  for (int i = 0; i < clouds.length; i++) {
    //paint
    ellipse(clouds[i], 150, 100, 100);
    ellipse(clouds[i], 200, 100, 100);
    ellipse(clouds[i]-50, 200, 100, 100);
    ellipse(clouds[i]+50, 200, 100, 100);
    
    //move
    clouds[i] += speed_clouds;
    if(clouds[i] >= 1300) clouds[i] = -100;
  }
  
  // HILLS - - -
  fill(backHill_color);
  for (int i = 0; i < hills.length; i++) {
    //paint
    ellipse(hills[i], 600, 600, 600);
    
    //move
    if (speed_fox > 0) hills[i] -= (speed_fox/3);
    if(hills[i] <= -300) hills[i] = 1500;
  }
  
  //FOREGROUND HILLS - - -
  fill(foreHill_color);
  for (int i = 0; i < fHills.length; i++) {
    // paint
    ellipse(fHills[i], 600, 300, 300);
    
    // move
    if (speed_fox > 0) fHills[i] -= (speed_fox/2);
    if(fHills[i] <= -300) fHills[i] = 1500;
  }
  
  // GROUND - - -
  fill(ground_color);
  rect(0, 600, 1200, 300);
  
  
  // FOX - - -
  image(fox_gif, fox_x, fox_y + fox_y_offset);
  
  // SNOW - - -
  fill(white);
  arc(snow, 800, 300, 300, radians(180), radians(360));  // Draw semicircle
   
  
  // move fox
  fox_x += speed_fox;
  
  // move snow
  // (once fox sniffes, snow moves towards him)
  if (!snow_lock) snow -= speed_fox;
  
  // Reset when fox is offscreen  
  if(fox_x >= 1200){
    snow = 1350;
    speed_fox = 0;
    
    snow_lock = true;
    
    fox_x = -300;
    fox_y_offset = 0;
  }
}


// Sound usage
void midiMessage(MidiMessage message) {
  int note = (int) (message.getMessage()[1] & 0xFF);
  
  // Depending on the note that comes from SC, a different animation with its respective horizontal movement is played
  // .ignoreRepeat() is used to run the gif just once, in order to coordinate movement with the sound input
  switch(note) {
    case 10: //idle
      speed_fox = 0;
      fox_y_offset = 0;
      fox_gif = new Gif(this, "fox-idle.gif");
      break;
      
    case 20: //walk
      speed_fox = 1.2;
      fox_y_offset = 0;
      fox_gif = new Gif(this, "fox-walk.gif");
      fox_gif.play();
      fox_gif.ignoreRepeat();
      break;
    
    case 30: //sniff
      speed_fox = 0;
      fox_y_offset = 0;
      fox_gif = new Gif(this, "fox-sniff.gif");
      snow_lock = false;
      break;
    
    case 40: //run
      speed_fox = 3.0;
      fox_y_offset = -15;
      fox_gif = new Gif(this, "fox-run.gif");
      fox_gif.play();
      fox_gif.ignoreRepeat();
      break;
      
    case 50: //jump
      speed_fox = 3.0;
      fox_y_offset = -112;
      fox_gif = new Gif(this, "fox-jump.gif");
      fox_gif.play();
      fox_gif.ignoreRepeat();
      break;
      
    default:
     break;
  }
  //println("fox x: "+fox_x+" sp "+speed_fox+" - y: "+(fox_y)+ " off "+fox_y_offset);
}

void keyPressed() {
  
  if (key == ' ') {
    snow = 1350;
    speed_fox = 0;
    
    snow_lock = true;
    
    fox_x = -300;
    fox_y_offset = 0;
  }
}
