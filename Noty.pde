/**
 Třída noty, obsahuje metody pro zapnutí a vypnutí not
 **/

// metoda která zapne notu
void zapniNotu( int nota, MidiChannel channel) {
  // spočte index noty
  for (int u=0; u<poleNot.length ; u++) {
    if (poleNot[0][u]==nota) {
      indexNoty=u;
    }
  }

  if (poleNot[1][indexNoty]==0) {
    channel.noteOn(nota, 80);
    poleNot[1][indexNoty]=1;  // true, je zapnuta
  }
}

// metoda která vypne notu
void vypniNotu( int nota, MidiChannel channel) {
  // spočte index noty 
  for (int u=0; u<poleNot.length ; u++) {
    if (poleNot[0][u]==nota) {
      indexNoty=u;
    }
  }

  if (poleNot[1][indexNoty]==1) {
    channel.noteOff(nota, 80);
    poleNot[1][indexNoty]=0;  // false, je vypnuta
  }
}

