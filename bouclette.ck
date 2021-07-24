// Debian 9.5 @ kirin
// Chuck 1.4.0.1 linux (pulse) 64-bit
// 20200601 / pierre@lesporteslogiques.net


int port_osc;
string filename;
string osc_adresse;

if( me.args() > 0 ) {
    me.arg(0) => filename;
    Std.atoi(me.arg(1)) => port_osc;
}

"/bouclette_" + filename => osc_adresse;

<<< "chuck : nom du fichier à traiter : " , filename >>>;
<<< "chuck : port OSC : " , port_osc >>>;
<<< "chuck : adresse OSC : " , osc_adresse >>>;

OscIn oin;                // définir le récepteur OSC
port_osc => oin.port;     // port de réception
OscMsg msg;
oin.addAddress( osc_adresse );

int fragments[100]; // Pour stocker les id et les numéros de shred...


while(true) {
  oin => now;
  
  while (oin.recv(msg) != 0) {
    msg.getInt(0)   => int action;
    msg.getInt(1)   => int index;
    msg.getFloat(2) => float start;
    msg.getFloat(3) => float dur;
    
    if (action == 0) { // Supprimer le shred associé à cet id
      <<< "supprimer index " , index, "fragments : ", fragments[index] >>>;
      Machine.remove(fragments[index]);
    }
    
    if (action == 1) { // Démarrer un nouveau shred
      Shred s;
      spork ~ grain(start, dur) @=> s;
      <<< "Index : " , index, " > nouveau shred : " , s.id() >>>;
      s.id() => fragments[index];
    }
  }
}

fun void grain(float start, float dur) {

  SndBuf gra => dac;
  me.dir() + "/" + filename => gra.read;
  while(1) {
    
    (dur * 3 * 44100) $ int => int gradur;
    (start * gra.samples()) $ int => gra.pos;
    if (gra.pos() < 0) 0 $ int => gra.pos;
    gradur :: samp => now;
  }
}

