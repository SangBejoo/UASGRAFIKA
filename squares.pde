

color[] colors;
int[] squares;
Game game;
int menuBarHeight;
PImage menuBtn;
int animationCoords;
Menu menu;

void setup() {

  size(500, 550);

  menuBtn = loadImage("images/menu.png");
  menuBarHeight = 50;
  game = new Game();
  menu = new Menu();
}


void draw() {
  background(100);
  noStroke();

  // menubar
  fill(200);
  textSize(26);
  textAlign(CENTER);
  text("Score: " + game.score, width/2, menuBarHeight/2+10);
  image(menuBtn, 0, 0, menuBarHeight, menuBarHeight);

  // game area
  // draw shapes
  if (game.currentView == "game") {
    for (int i=0; i<10; i++) {
      for (int j=0; j<10; j++) {
        fill(colors[squares[i*10+j]]);
        if (game.shapes.equals("squares")) {
          rectMode(CENTER);
          rect((j*width/10+3)+(width/10-6)/2, (i*(height-menuBarHeight)/10+3+menuBarHeight)+(width/10-6)/2, width/10-6, (height-menuBarHeight)/10-6);
        } else if (game.shapes.equals("ellipses")) {
          ellipseMode(CENTER);
          ellipse((j*width/10+3)+(width/10-6)/2, (i*(height-menuBarHeight)/10+3+menuBarHeight)+(width/10-6)/2, width/10-6, (height-menuBarHeight)/10-6);
        } else if (game.shapes.equals("octagons")) {
          if (game.animate == true) {
            pushMatrix();
            translate((j*width/10+3)+(width/10-6)/2, (i*(height-menuBarHeight)/10+3+menuBarHeight)+(width/10-6)/2);
            rotate(frameCount / -((20.0*squares[i*10+j])+20)); 
            polygon(0, 0, (width/10-6)/2, 8);
            popMatrix();
          } else {
            polygon((j*width/10+3)+(width/10-6)/2, (i*(height-menuBarHeight)/10+3+menuBarHeight)+(width/10-6)/2, (width/10-6)/2, 8);
          }
        } else if (game.shapes.equals("stars")) {
          if (game.animate == true) {
            pushMatrix();
            translate((j*width/10+3)+(width/10-6)/2, (i*(height-menuBarHeight)/10+3+menuBarHeight)+(width/10-6)/2);
            rotate(frameCount / ((20.0*squares[i*10+j])+20)); 
            star(0, 0, (width/10-6)/2, (width/10-6)/2/10, 3);
            popMatrix();
          } else {
            star((j*width/10+3)+(width/10-6)/2, (i*(height-menuBarHeight)/10+3+menuBarHeight)+(width/10-6)/2, (width/10-6)/2, (width/10-6)/2/10, 3);
          }
        }
      }
    }
  }

  if (game.currentView == "menu") {
    menu.drawMenu();
    // menu animation
    if (animationCoords < width) {
      animationCoords += 50;
      menu.x += 50;
    }
    menu.webSiteMouseOver();
  }

  // check if the game is over
  for (int i=0; i<squares.length; i++) {
    if (checkSquares(i) && squares[i] != colors.length-1) {
      game.gameOver = false;
      break;
    } else {
      game.gameOver = true;
    }
  }
  // print game over message
  if (game.gameOver && game.currentView == "game") {
    fill(255);
    textSize(64);
    text("game over", width/2, height/2);
    game.animate = false;
  }
}



void mouseClicked() {
  if (mouseX >= 0 && mouseX <= 50 && mouseY >= 0 && mouseY <= 50) {
    // menu button is pressed
    if (!game.menuFlag) {
      game.currentView = "menu";
      game.menuFlag = true;
    } else {
      game.currentView = "game";
      game.menuFlag = false;
      animationCoords = 0;
      menu.x = -500;
    }
  }

  // delete and move shapes
  if (game.currentView == "game") {
    for (int i=0; i<10; i++) {
      for (int j=0; j<10; j++) {
        if (mouseX >= j*width/10+3 && 
          mouseX <= (j*width/10+3) + (width/10-6) &&
          mouseY >= i*(height-menuBarHeight)/10+3+menuBarHeight && 
          mouseY <= (i*(height-menuBarHeight)/10+3+menuBarHeight) + ((height-menuBarHeight)/10-6)) {
          if (squares[i*10+j] != colors.length-1) {
            int countedDeletedSquares = delSquares(i*10+j, true);
            if(countedDeletedSquares>0){
              game.score += pow(countedDeletedSquares - 1, 2);
            }
            
            for (int countDel=0; countDel<countedDeletedSquares+1; countDel++) {
              moveSquares();
            }
          }
        }
      }
    }
  }

  if (game.currentView == "menu") {
    menu.newGameBtnClick();
    menu.shapeChoiceClick();
    menu.webSiteClick();
  }
}

void mouseMoved() {
  // hover effect of the new game button
  if (game.currentView == "menu") {
    if (mouseY>menu.y && mouseY<50+80) {
      menu.newGameBtnColor = color(150);
    } else {
      menu.newGameBtnColor = menu.menuColor;
    }
  }
}

// check if there are the same color shapes near by the shape
boolean checkSquares(int i) {
  if (
    ((i%10 != 0) && (squares[i-1] == squares[i])) || 
    (((i+1)%10 != 0) && (squares[i+1] == squares[i])) || 
    ((i>=10) && (squares[i-10] == squares[i])) || 
    ((i<90) && (squares[i+10] == squares[i]))
    ) {
    return true;
  } else {
    return false;
  }
}

// delete the shape if there is the same color shape near and calls the same function recursivelly
int delSquares(int i, boolean firstrun) {

  int deletingValue;
  int countingDeletedSquares = 0;
  deletingValue = squares[i];

  // if there are not the same color shapes near by this, exit the function
  if (firstrun) {
    if (checkSquares(i)) {
    } else {
      return 0;
    }
  }

  // del the shape
  squares[i] = colors.length-1; // the last element of colors is the color of "deleted" shapes
  countingDeletedSquares++;

  if (i%10 != 0) {
    // check left
    if (squares[i-1] == deletingValue) {
      countingDeletedSquares += delSquares(i-1, false);
    }
  }

  if ((i+1)%10 != 0) {
    // check right
    if (squares[i+1] == deletingValue) {
      countingDeletedSquares += delSquares(i+1, false);
    }
  }

  if (i>=10) {
    // check up
    if (squares[i-10] == deletingValue) {
      countingDeletedSquares += delSquares(i-10, false);
    }
  }

  if (i<90) {
    // check down
    if (squares[i+10] == deletingValue) {
      countingDeletedSquares += delSquares(i+10, false);
    }
  }
  return countingDeletedSquares;
}

void moveSquares() {

  // move the shapes from top to bottom
  for (int i=squares.length-1; i>=0; i--) {
    if (squares[i] == colors.length-1 && i/10>=1) {
      squares[i] = squares[i-10];
      squares[i-10] = colors.length-1;
    }
  }

  // move shapes from right to left
  // first check if the col is empty
  for (int i=90; i<100; i++) {
    boolean moveToLeft = true;
    for (int k=0; k<10; k++) {
      if (squares[k*10+i%10] != colors.length-1) {
        moveToLeft = false;
      }
    }
    // move cols to left
    if (moveToLeft) {
      for (int k=0; k<10; k++) {
        for (int j=i; j<100; j++) {
          if (j%10 != 9) {
            squares[k*10+j%10] = squares[k*10+j%10+1];
          } else {
            squares[k*10+j%10] = colors.length-1;
          }
        }
      }
    }
  }
}

class Game {
  int score;
  String shapes; // blocks or circles etc
  String currentView; // what view is current. The views are (game, menu, settings, help)
  boolean gameOver; // game over flag
  boolean menuFlag;
  boolean animate;
  Game() {
    this.score = 0;
    String[] s = loadStrings("shapes");
    this.shapes = s[0]; // you need to change it and take value from file   
    this.gameOver = false;
    this.currentView = "game";
    this.menuFlag = false;
    this.animate = true;
    newGame();
  }
  void newGame() {
    colors = new color[6];
    animationCoords = 0;
    
    for (int i=0; i<colors.length-2; i++) {
      int r = int(random(150, 255)), g = int(random(255)), b = int(random(255));
      while (r==g && r==b) {
        r = int(random(150, 255));
        g = int(random(255));
        b = int(random(255));
      }
      colors[i] = color(r, g, b);
    }
    colors[colors.length-1] = color(110);

    squares = new int[100];
    for (int i=0; i<100; i++) {
      squares[i] = int(random(0, colors.length-1));
    }
  }
  boolean checkGame() {
    for (int i = 0; i<squares.length; i++) {
      if (checkSquares(i)) {
        return true;
      }
    }
    this.gameOver = true;
    return false;
  }
}

class Menu {
  int x, y;
  color newGameBtnColor;
  color menuColor;
  Menu() {
    this.x = -500;
    this.y = 50;
    this.newGameBtnColor = color(120);
    this.menuColor = color(120);
  }
  void drawMenu() {
    rectMode(CORNER);
    ellipseMode(CORNER);
    fill(this.menuColor);
    rect(this.x, this.y, width, height-50);

    drawNewGameBtn();
    drawShapesChoice();
    drawAboutInfo();
  }
  void drawNewGameBtn() {
    fill(newGameBtnColor);
    rect(this.x, this.y, width, 80);
    fill(200);
    textSize(26);
    textAlign(CENTER);
    text("New game", this.x+width/2, this.y+50);
  }
  void drawShapesChoice() {
    rect(this.x+10, this.y+90, width-20, 200, 5);
    fill(110);
    if (game.shapes.equals("squares")) {
      fill(150, 50, 80);
    }
    rect(20, this.y+90+10, 30, 30);

    fill(110);
    if (game.shapes.equals("ellipses")) {
      fill(150, 50, 80);
    }
    ellipseMode(CORNER);
    ellipse(this.x+20, this.y+150, 30, 30);

    fill(110);
    if (game.shapes.equals("octagons")) {
      fill(150, 50, 80);
    }
    polygon(this.x+20+15, this.y+215, 15, 8);

    fill(110);
    if (game.shapes.equals("stars")) {
      fill(150, 50, 80);
    }
    star(this.x+20+15, this.y+250+15, 15, 2, 3);

    fill(this.menuColor);
    text("Choose the shape", this.x+width/2, this.y+50+80+65);
  }

  void drawAboutInfo() {
    fill(200);
    rect(this.x+10, this.y+90+200+10, width-20, 190, 5);
    fill(this.menuColor);

    text("About the game", this.x+width/2, this.y+90+200+10+30);
    textSize(14);
    text("Squares, 0.0.1", this.x+width/2, this.y+90+200+10+30+25);
    text("Clear the field from shapes.", this.x+width/2, this.y+90+200+10+30+50);
    text("Created with Processing programming language.", this.x+width/2, this.y+90+200+10+30+70);
    text("HUMAN", this.x+width/2, this.y+90+200+10+30+90);
    fill(30, 30, 200);
    text("https://github.com/SangBejoo", this.x+width/2, this.y+90+200+10+30+110);
    fill(this.menuColor);
    textSize(12);
    text("This program comes with absolutely no warranty.\nSee the GNU General Public License, version 3 or later for details.", this.x+width/2, this.y+90+200+10+30+130);
  }

  void webSiteClick() {
    if (mouseX>=this.x+width/2-50 && mouseX<=this.x+width/2+50 && mouseY>=this.y+90+200+10+30+110-14 && mouseY<=this.y+90+200+10+30+110) {
      link("https://github.com/SangBejoo");
    }
  }

  void webSiteMouseOver() {
    if (mouseX>=this.x+width/2-50 && mouseX<=this.x+width/2+50 && mouseY>=this.y+90+200+10+30+110-14 && mouseY<=this.y+90+200+10+30+110) {
      cursor(HAND);
    } else {
      cursor(0);
    }
  }

  void shapeChoiceClick() {
    if (mouseX>=this.x+20 && mouseX<=this.x+20+30 && mouseY>=this.y+100 && mouseY<=this.y+100+30) {
      game.shapes = "squares";
      String[] s = {game.shapes};
      saveStrings("shapes", s);
    } else if (mouseX>=this.x+20 && mouseX<=this.x+20+30 && mouseY>=this.y+150 && mouseY<=this.y+150+30) {
      game.shapes = "ellipses";
      String[] s = {game.shapes};
      saveStrings("shapes", s);
    } else if (mouseX>=this.x+20 && mouseX<=this.x+20+30 && mouseY>=this.y+215-15 && mouseY<=this.y+215+15) {
      game.shapes = "octagons";
      String[] s = {game.shapes};
      saveStrings("shapes", s);
    } else if (mouseX>=this.x+20 && mouseX<=this.x+20+30 && mouseY>=this.y+265-15 && mouseY<=this.y+265+15) {
      game.shapes = "stars";
      String[] s = {game.shapes};
      saveStrings("shapes", s);
    }
  }
  void newGameBtnClick() {
    if (mouseY>menu.y && mouseY<50+80) {
      menu.newGameBtnColor = color(100);
      game = new Game();
      this.x = -500;
    } else {
      menu.newGameBtnColor = menu.menuColor;
    }
  }
}


// these two functions i took from examples on processing.org website
void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
