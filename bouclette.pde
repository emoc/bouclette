/*
  Discussions entre processing et chuck
  Lire en boucle plusieurs grains de sons d'un même fichier
 Quimper, Dour Ru, 20200601 / pierre@lesporteslogiques.net
 Processing 3.5.3 + ControlP5 2.2.6 + OscP5 0.9.9
 chuck version: 1.4.0.1 linux (pulse) 64-bit
 @ kirin / Debian Stretch 9.5
*/

import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

ArrayList<Grain> grains = new ArrayList<Grain>();

int id = 0;
float duree_morceau = 58.16; // en secondes
float dur;

PImage wave;

String fichier;
float duree;
int port_osc;

void setup() {
  size (800, 400);
  if (args != null) {
    println(args.length);
    for (int i = 0; i < args.length; i++) {
      println(args[i]);
    }
    fichier = args[0];
    duree = float(trim(args[1]));
    port_osc = int(trim(args[2]));
    println("fichier reçu dans processing : " + fichier);
    println("durée reçue dans processing : " + duree);
    //exit();
  } else theEnd();
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", port_osc);
  wave = loadImage(fichier + ".png");
  
}

void draw() {

  background(0);
  image(wave,0,0);

  // Montrer la position et le fragment bouclé
  fill(128, 50);
  stroke(128, 50);
  strokeWeight(0.5);
  dur = (((duree_morceau * 44100) / width) / ((mouseY / (float)height) * (3 * 44100))); 
  float pixels_par_seconde = (float)width / duree_morceau; // x pixel = 1 seconde
  float duree_extrait = (1 - (mouseY / (float)height)) * 3 ; // 3 secondes max
  dur = pixels_par_seconde * duree_extrait;
  
  line(0, mouseY, width, mouseY);
  rect(mouseX, 0, dur, height);
  for (int i = grains.size() - 1; i >= 0; i--) {
    Grain g = grains.get(i);
    g.miseajour();
  }
}

void keyPressed() {
  if (key == 'p') ajouterGrain();
  if (key == 'd') supprimerGrain(mouseX, mouseY);
  if (key == 'c') resetGrain();
}

void ajouterGrain() {
  id ++;
  if (id < 100) {
    grains.add( new Grain(mouseX, mouseY, id) );

    OscMessage myMessage = new OscMessage("/bouclette_" + fichier);
    float xn = mouseX / (float)width;  // normaliser les valeurs
    float yn = mouseY / (float)height; // normaliser les valeurs
    myMessage.add(1);
    myMessage.add(id);
    myMessage.add(xn);
    myMessage.add(1 - yn); // inverser, c'est plus intuitif, le zéro est en bas!
    oscP5.send(myMessage, myRemoteLocation);
  } else {
    background(255, 0, 0);
    println("trop de fragments!");
  }
}

void supprimerGrain(float x, float y) {
  for (int i = grains.size() - 1; i >= 0; i--) {
    Grain g = grains.get(i);
    if (dist(x, y, g.x, g.y) < 6) {
      grains.remove(i);
      OscMessage myMessage = new OscMessage("/bouclette_" + fichier);
      myMessage.add(0);
      myMessage.add(g.id);
      myMessage.add(0);
      myMessage.add(0);
      oscP5.send(myMessage, myRemoteLocation);
    }
  }
}

void resetGrain() {
  for (int i = grains.size() - 1; i >= 0; i--) {
    Grain g = grains.get(i);
    grains.remove(i);
    OscMessage myMessage = new OscMessage("/bouclette_" + fichier);
    myMessage.add(0);
    myMessage.add(g.id);
    myMessage.add(0);
    myMessage.add(0);
    oscP5.send(myMessage, myRemoteLocation);
  }
  id = 0;
}

void theEnd() {
  exit();
}
