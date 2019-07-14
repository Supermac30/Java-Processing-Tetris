package processing.test.tetris;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import cassette.audiofiles.SoundFile; 
import java.util.Arrays; 
import org.gamecontrolplus.gui.*; 
import org.gamecontrolplus.*; 
import net.java.games.input.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class tetris extends PApplet {

/*  
 * @author Mark Bedaywi
 * This is a version of Tetris for my 11U CPT
 * 
 * A Tetrimino is the name of a block in Tetris, it is made up of four blocks and is connected othogonally
 * A line is cleared there is no empty space
 * A line is moved down if there is only empty space under it
 * To ensure no piece drought every piece will come once every 7 times
 */
 





//import processing.net.*;

ControlIO control;
ControlDevice stick;
int delay = 100;
float X; // holds the value of left and right on the D-Pad
float Y; // holds the value of up and down on the D-Pad
boolean XBUTTON; // holds whether or not x is pressed
boolean CIRCLE; // holds whether or not circle is pressed
boolean TRIANGLE; // holds whether or not triangle is pressed
int lastPressed0 = 0; // holds the time since a direction was pressed
int lastPressed1 = 0; // holds the time since a button was pressed
int wait = 5; // holds the amount of frames until a button on the controller can be pressed again

SoundFile music;
SoundFile drop;
SoundFile clear;
String musicName = "music.mp3";
String dropName = "drop.ogg";
String clearName = "clearSingle.mp3";
String path;

Grid grid; // holds the grid that will be used

boolean fall = true; // holds whether or not the tetrimino should fall
int time = 31; // holds the time since the tetrimino hit a surface
int screen = 0; // holds the screen you are currently on
int linesCleared = 0; // holds the number of lines cleared
boolean pressedHold = false; // holds whether or not hold has been pressed this round
int[] nextTetrimino = {-1,0,0,0,0,0,0,-1}; // holds the values of the next seven tetriminos
int randomLoc; // holds the random location that will be given out in the chooseNext() function
int rand; // holds the random value that will be returned by chooseNext()
Tetrimino boy = new Tetrimino(chooseNext(), 0); // holds the tetrimino currently falling
int upNext = chooseNext(); // holds the identity of the tetrimino coming up next
Tetrimino nextBoy = new Tetrimino(upNext, 1); // holds the tetrimino that will come up next
Tetrimino hold; // holds the tetrimino in hold
Tetrimino temp; // is a temporary tetrimino for switching boy and hold
int difficulty = 50; // holds the difficulty of the game

//size(600, 800);
Button startButton;
Button hostServer;
Button joinServer;
Button settingsButton;
Button exitButton;
Button enableController;
Button setDifficulty;
Button setSensitivity;
Button returnToMenu;
Button returnGameover;

boolean controller = false; // holds whether or not you are playing with a compatable controller
/*
Server server = new Server(this, 7777); // holds the server
Client client; // holds the client
boolean onlinePlay = false; // holds whether or not you are playing online
boolean searchingForServer = false; // holds whether or not you started to search for a server
String inputtedIP = ""; // holds the input in the join screen
String myIP = Server.ip(); // holds the ip of the user
boolean isServer = false; // holds whether or not the user is the host
int enemyScore; // holds the score the enemy
String clientName; // holds the name of the client
int attackEnemy = 0; // holds how many lines to send the enemy
*/
public int[][] copy2d(int array2d[][]){
  // a helper function
  // Copies a 2d array, why isn't this built into java?
  int temp[][] = new int[array2d.length][array2d[0].length];
  for (int i = 0; i < array2d.length; i++){
    for (int j = 0; j < array2d[i].length; j++){
      temp[i][j] = array2d[i][j];
    }
  }
  return temp;
}

public int chooseNext(){
  // chooses the next 7 tetriminos that are all different in random order.
  // If the next 7 tetriminos are already chosen, -1 didn't reach index 0 the next index is returned and all numbers are moved back.
  // To put the numbers from 0 to 6 in random order an algorithm close to shuffling cards is used, where a random index is taken out and another index is chosen from a smaller arraylist.

  if (nextTetrimino[0] == -1){
    ArrayList<Integer> values = new ArrayList<Integer> (Arrays.asList(0,1,2,3,4,5,6));
    for (int i = 0; i < 7; i++){
      randomLoc = (int) random(0,7-i);
      nextTetrimino[i] = values.get(randomLoc);
      values.remove(randomLoc);
    }
    nextTetrimino[7] = -1;
  }
  rand = nextTetrimino[0];
  for (int i = 0; i < 7; i ++){
    nextTetrimino[i] = nextTetrimino[i+1];
  }
  return rand;
}

public void addPoints(int linesCleared){
  // adds points depending on the number of lines cleared
  switch(linesCleared){
    case 1:
      grid.score += 40 * (grid.level+1);
      break;
    case 2:
      grid.score += 100 * (grid.level+1);
      break;
    case 3:
      grid.score += 300 * (grid.level+1);
      break;
    case 4:
      grid.score += 1200 * (grid.level+1);
      break;
  }
  grid.score += boy.softDrop; // adds points for the drop

}

public void hold(){
  // puts a block in hold and makes the block in hold, if there is one, come into the board
  temp = new Tetrimino(boy, 0); // stores boy in temp so that boy and hold can switch
  if (pressedHold){
    return;
  }
  pressedHold = true;
  if (hold == null){
    boy = new Tetrimino(upNext, 0);
    upNext = chooseNext();
    nextBoy = new Tetrimino(upNext, 1);
  }
  else{
    boy = new Tetrimino(hold, 0); // moves the tetrimino in hold into the board
  }
  hold = new Tetrimino(temp, 2); // moves the tetrimino into hold

}

public void gameScreen(){
  // holds the game screen
  grid.createGame();
  boy.makeBlocks();
  nextBoy.makeBlocks();
  if (hold != null){
    hold.makeBlocks();
  }
  
  // creates a new block if the block reaches the ground
  if (boy.checkIfEnd()) {
    time = fall ? 0 : time; // resets time at 0 if the tetrimino hits the ground but only at first contact
    fall = false; // stops the tetrimino from falling
    time += 1; 
    
    if (boy.hardDrop || time == 40){ // gives the player some time to move the tetrimino until the block is made perminant
      boy.makePerminant();
      boy = new Tetrimino(upNext, 0);
      upNext = chooseNext();
      nextBoy = new Tetrimino(upNext, 1);
      fall = true;
      pressedHold = false;
    }
  }
  
  if (!boy.checkIfEnd() && !fall){ //continues falling if the tetrimino escapes the surface during the safe period
    fall = true;
  }
  
  // makes the block fall at a certian speed
  if (frameCount % ceil(60 / pow(1 + difficulty*2/100 ,grid.level))  == 0) {
    boy.fall();
  }
  
}

public void gameOverScreen(){ 
  // comes up when the player loses  
  background(0);
  textSize(40);
  text("GAMEOVER", width/2 - 110, 80);
  text("You scored ", width/2 - 110, 200);
  text(grid.score, width/2 - 11*(Integer.toString(grid.score).length()), 250);
  text("point"+ (grid.score != 1 ? "s":"") +"!", width/2 - 70, 300);
  returnGameover.buildButton();
  if (returnGameover.isPressed()){
    hold = null;
    delay(150);
    screen = 0;
  }
}

public void settingsScreen(){
  background(100,100,100);
  if (controller){
    enableController.text = "Disable Controller";
    setSensitivity.locked = false;
  }
  else{
    enableController.text = "Enable Controller";
    setSensitivity.locked = true;
  }

  textSize(width/40);
  text("Remember to connect your controller before opening the file", width*2/15, height*43/160);
  
  // enables or disables your controller
  enableController.buildButton();
  returnToMenu.buildButton();
  setDifficulty.buildButton();
  setSensitivity.buildButton();
  
  if (enableController.isPressed()){
    delay(100);
    controller = !controller;
    if (controller){
      controllerSetup();
    }
  }
  if (setDifficulty.isPressed()){
    delay(100);
    difficulty = (difficulty + 10) % 110;
    setDifficulty.text = "Difficulty: " + difficulty;
  }
  if (setSensitivity.isPressed()){
    delay(100);
    wait = (wait + 1) % 10;
    setSensitivity.text = "Controller Sensitivity: " + (10-wait);
  }
  if (returnToMenu.isPressed()){
    delay(200);
    screen = 0;
  }
}

public void menuScreen(){
  // Is the menu that first comes up 
  background(100,100,100);
  // 600*800
  textSize(width*8/75);
  text("Tetris",width/3, height/8);
  startButton.buildButton();
  settingsButton.buildButton();
  hostServer.buildButton();
  joinServer.buildButton();
  exitButton.buildButton();
  
  if (hostServer.isPressed()){
    startButton.text = "Start Battle";
    screen = 6;
  }
  if (joinServer.isPressed()){
    screen = 7;
  }
  if (startButton.isPressed()){
    screen = 3;
  }
  if (settingsButton.isPressed()){
    delay(200);
    screen = 5;
  }
  if (exitButton.isPressed()){
    exit();
  } 
}

public void hostScreen(){
  /*
  // holds the screen that comes up when you are the server
  background(100,100,100);
  textSize(64);
  text("Tetris",width/2 - 100, 100);
  textSize(20);
  text("Your IP is: " + myIP, 100, 400);
  text("Hosting on port 7777", 100, 450);
  client = server.available();
  server.write("wait");
  
  if (client == null){
    startButton.locked = true;
  } else {
    startButton.locked = false;
  }
  startButton.buildButton();
  
  if (clientName != null && client != null){
    text("You are connected to "+clientName, 100, 500);
  }
  
  if (startButton.isPressed() && client != null) {
    println("Game Started");
    server.write("start");
    onlinePlay = true;
    isServer = true;
    screen = 3;
  }
  */
}
/*
void serverEvent(Client client){
  // runs when the enemy connects
  clientName = client.ip();
}
*/

public void joinScreen(){
  // holds the screen that comes up when you are the client
  /*
  background(100,100,100);
  textSize(64);
  text("Tetris",width/2 - 100, 100);
  textSize(20);
  if (!searchingForServer){
    text("Type in the IP of the server", 100, 250);
    text(inputtedIP, 100, 300);
    if (keyPressed && key != ENTER && key != BACKSPACE){
      inputtedIP += key;
      delay(200);
    }
    else if (keyPressed && key == ENTER){
      text("Searching for server", 100, 350);
      client = new Client(this, inputtedIP, 7777);
      searchingForServer = true; 
    }
    else if (keyPressed && key == BACKSPACE && inputtedIP.length() != 0){
      inputtedIP = inputtedIP.substring(0,inputtedIP.length()-1);
      delay(50);
      
    }
  }
  else{
    client.write(10);
    String received = client.readString();
    println(received);
    if (received != null){ //<>//
      if (received.equals("wait")){
        text("Waiting for server to start game", 100, 300);
        onlinePlay = true;
      } else if (received.equals("start")){
        screen = 3;
      }
    } else {
      text("Server not found", 100, 300);
    }
  }
  */
}

public void setup() {
  //runs once
  frameRate(30);
  
  
  //size(600, 800);
  startButton = new Button(width/6, height/5.3f, width*2/3, height/8, "Single Player");
  hostServer = new Button(width/6, height*3/8, width/3, height/8, "Host Server");
  joinServer = new Button(width/2, height*3/8, width/3, height/8, "Join Server");
  settingsButton = new Button(width/6, height*9/16, width*2/3, height/8, "Settings");
  exitButton = new Button(width/6, height*6/8, width*2/3, height/8, "Quit");
  enableController = new Button(width/6, height/8, width*2/3, height/8, "Enable controller");
  setDifficulty = new Button(width/6, height/2, width*2/3, height/8, "Difficulty: " + difficulty);
  setSensitivity = new Button(width/6, height*5/16, width*2/3, height/8, "Controller Sensitivity: "+ (10-wait));
  returnToMenu = new Button(width/6, height*11/16, width*2/3, height/8, "Return to the menu");
  returnGameover = new Button(width/6, height/2, width*2/3, height/8, "Return to the menu");
}

public void gameSetup(){
  // setups up the game
  grid = new Grid();
  
  frameRate(60);
  //initialises occupied blocks
  for (int i = 0; i<20; i++) {
    for (int j = 0; j<10; j++) {
      grid.occupied[i][j] = false;
    }
  }
  for (int i = 0; i<10; i++) {
    grid.occupied[20][i] = true;
  }
  
  // plays the song
  /*
  path = sketchPath(musicName);
  music = new SoundFile(this, path);
  music.loop();
  
  //sets up the sound effects
  path = sketchPath(clearName);
  clear = new SoundFile(this, path);
  path = sketchPath(dropName);
  drop = new SoundFile(this, path);
  */
  screen = 1;
}

public void controllerSetup(){
  //connects to controller - remember to connect control before starting sketch
  control = ControlIO.getInstance(this);
  if (stick == null){
    stick = control.getMatchedDevice("PS1Classic");
  }
  if (stick == null){
    println("no recognised controller connected");
  }
}

public void loadingScreen(){
  // makes a loading screen
  background(255,255,255);
  fill(0);
  textSize(20);
  text("Please wait, loading...", 200, 100);
  if (!controller){
    text("Keyboard Controls:", 20, 200);
    text("- Left and Right for movement", 40, 250);
    text("- Up for a Hard Drop", 40, 300);
    text("- Down for a Soft Drop", 40, 350);
    text("- A and D for rotation", 40, 400);
    text("- W to hold", 40, 450);
  }
  screen = 4;
}

public void draw() {
  //loops
  touchInput();
  if (controller){
    controllerInput();
  }
  
  // holds the current screen of the program
  switch(screen){
    case 0:
      menuScreen();
      break;
    case 1:
      gameScreen();
      break;
    case 2:
      gameOverScreen();
      break;
    case 3:
      loadingScreen();
      break;
    case 4:
      gameSetup();
      break;
    case 5:
      settingsScreen();
      break;
    case 6:
      hostScreen();
      break;
    case 7:
      joinScreen();
      break;
  }
}

int[] startPress = new int[3]; // holds the point at which the press started and the time
public void mousePressed(){
  // works with the touchInput function to take touch input
  startPress[0] = mouseX;
  startPress[1] = mouseY;
  startPress[2] = frameCount;
  if (screen == 1){
    if (mouseX > grid.gameWidth+width/60 && mouseX < grid.gameWidth+width*3/10 && mouseY > height*67/100 && mouseY < height*179/200){
      hold();
    }
  }
}
public void touchInput(){
  // This function takes in input from a phone, also works using the mouse
  if (mousePressed && screen == 1){
    if (mouseX - 50 > startPress[0] && frameCount - startPress[2] > 10){
      boy.right();
      startPress[2] = frameCount;
    }
    else if (mouseX + 50 < startPress[0] && frameCount - startPress[2] > 10){
      boy.left();
      startPress[2] = frameCount;
    }
    else if (mouseY - 50 > startPress[1] && frameCount - startPress[2] > 10){
      boy.fall();
      startPress[2] = frameCount;
    }
    else if (mouseY + 50 < startPress[1] && frameCount - startPress[2] > 10){
      boy.hardDrop();
      startPress[2] = frameCount + 10; // so that it doesn't accidentaly drop twice
    }
    else if (frameCount - startPress[2] > 20){
      boy.rotate(1);
      startPress[2] = frameCount;
    }
  }
}
  
public void controllerInput(){
  // This function takes in input from the controller and handles it
  try{
    X = stick.getSlider("X").getValue();
  }
  catch(Exception e){
    controller = false;
    return;
  }
  Y = stick.getSlider("Y").getValue();
  XBUTTON = stick.getButton("XBUTTON").pressed();
  CIRCLE = stick.getButton("CIRCLE").pressed();
  TRIANGLE = stick.getButton("TRIANGLE").pressed();
  
  // If the time since last press is long enough handle input
  if (frameCount - lastPressed0 > wait){
    if (X > 0.5f){
      boy.right();
    }
    if (X < -0.5f){
      boy.left();
    }
    if (Y > 0.5f ){
      boy.fall();
      boy.softDrop++;
    }
    if (Y < -0.5f ){
      boy.hardDrop();
    }
    lastPressed0 = frameCount;
  }
  if (frameCount - lastPressed1 > wait){
    if (XBUTTON){
      boy.rotate(-1);
    }
    if (CIRCLE){
      boy.rotate(1);
    }
    if (TRIANGLE){
      hold();
    }
    lastPressed1 = frameCount;
  }
}


public void keyPressed() {
  //handles a key being pressed
  if (!controller){
    if (keyCode == LEFT) {
      boy.left();
    }
    if (keyCode == RIGHT) {
      boy.right();
    }
    if (keyCode == UP) {
      boy.hardDrop();
    }
    if (keyCode == DOWN) {
      boy.fall();
      boy.softDrop++;
    }
    if (key == 'a'){
      boy.rotate(-1);
    }
    if (key == 'd'){
      boy.rotate(1);
    } 
    if (key == 'w'){
      hold();
    }
  }
}
class Button{
  // makes the UI much easier to work with
  float buttonX; // holds the x coordinate of the button
  float buttonY; // holds the y coordinate of the button
  float buttonWidth; // holds the width of the button
  float buttonHeight; // holds the height of the button
  String text; // holds the text within the button
  int fill = color (0,0,0); // holds the color of the button
  int outline = color (255,255,255); // holds the color of the outline of the button
  int textColor =  color (255,255,255); // holds the color of the text
  boolean locked = false; // holds whether or not the button can currently be used
  int textSize = width/30;
  
  Button(float buttonX, float buttonY, float buttonWidth, float buttonHeight, String text){
    // button constructor
    this.buttonX = buttonX;
    this.buttonY = buttonY;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.text = text;
  }
  public void buildButton(){
    // creates the button
    fill(fill);
    stroke(outline);
    textSize(textSize);
    rect(buttonX,buttonY,buttonWidth,buttonHeight);
    fill(textColor);
    text(text, buttonX+(buttonWidth*0.5f) - text.length()*this.textSize/4.5f, buttonY+(buttonHeight*0.5f) + (0.2f*textSize));
  }
  public boolean isPressed(){
    // returns whether or not the button has been pressed
    if (this.locked){
      fill = color(211,211,211);
      return false;
    }
    if (mousePressed){
      if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight){
        return true;
      }
    }
    if (this.isHover()){
      fill = color(50,50,50);
    }
    else{
      fill = color(0,0,0);
    }
    return false;
  }
  
  public boolean isHover(){
    // returns whether or not the button is hovered over
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight){
        return true;
    }
    return false;
  }
}
class Grid{
  int score = 0; // holds the players score
  int blockWidth = width/15; // holds the pixel width of each square block
  int gameWidth = blockWidth*10; // holds the length of the borad
  int gameHeight = blockWidth*20; // holds the height of the board
  boolean occupied[][] = new boolean[21][10]; // stores all the currently occupied blocks
  int colorMap[][] = new int[20][10]; // stores the color of all the occupied blocks
  int level = 0; // holds the level currently on
  
  boolean send = false; // holds whether or not a packet should be sent
  
  Grid(){}
  
  public void createGame() {
    // creates the background
    background(211, 211, 211);
    for (int i = 0; i <= gameWidth + 0; i += blockWidth) {
      line(i, 0, i, gameHeight);
    }
    for (int i = 0; i <= gameHeight + 0; i += blockWidth) {
      line(0, i, gameWidth, i);
    }
    // 600*800
    textSize(width*4/75);
    // place all outside board elements gameWidth+width/60 away
    fill(0,0,0);
    text("score: "+score, gameWidth+width/60, height*9/200);
    text("level: "+level,gameWidth+width/60, height*43/400);
    text("next block", gameWidth+width/60, height*93/400);
    rect(gameWidth+width/60, height*27/100, width*3/10, width*3/10);
    text("hold", gameWidth+10, height*5/8);
    fill(255,255,255);
    rect(gameWidth+width/60, height*67/100, width*3/10, width*3/10);
  
    // builds all blocks in occupied
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 10; j++) {
        if (occupied[i][j]) {
          fill(colorMap[i][j]);
          rect(j*blockWidth, i*blockWidth, blockWidth, blockWidth);
        }
      }
    }
    /*
    //handles the sockets in game
    if (onlinePlay){
      if (isServer){
        if (client != null){
          try{
            String[] received = client.readString().split(" ");
            enemyScore = parseInt(received[0]);
            attacked(parseInt(received[1]));
          } catch(Exception e){}
        }
        if (send){
          server.write(score + " " + attackEnemy);
          send = false;
        }
      } else {
        if (send){
          client.write(score + " " + attackEnemy);
          send = false;
        }
        if (client.available() > 0){
          try{
            String[] received = client.readString().split(" ");
            enemyScore = parseInt(received[0]);
            attacked(parseInt(received[1]));
          } catch(Exception e){}
        }
      }
    }
    */
  }

  public void attacked(int lines){
    // adds a line when you get attacked
    println("oh no" + lines);
    for (int i = 0; i < lines; i++){
      int place = (int)random(0,11);
      this.moveUp();
      for (int j = 0; j < 10; j++){
        if (j != place){
          this.occupied[0][j] = true;
          this.colorMap[0][j] = color(211,211,211);
        }
      }
    }
  }
  
  public void moveUp(){
    // moves up all the blocks
    for (int i = 0; i < 20; i++){
      this.occupied[i] = occupied[i+1].clone();
      this.colorMap[i] = colorMap[i+1].clone();
    }
  }
  
  public void moveDown(int lineNum){
    //moves down all blocks starting from lineNum
    for (int i = lineNum; i > 0; i--){
      this.occupied[i] = occupied[i-1].clone();
      this.colorMap[i] = colorMap[i-1].clone();
    }
  }
  
  public void clearLine(int lineNum){
    //clears the line lineNum
    for (int i = 0; i < 10; i++){
      this.occupied[lineNum][i] = false;
    }
    //clear.play();
    this.moveDown(lineNum);
  }
  
  public void fixBoard(){
    // This function checks if any lines will be cleared or moved down
    int totalCleared = 0;
    for (int i = 0; i < 20; i++){
      boolean allFilled = true;
      boolean allEmpty = false;
      for (int j = 0; j < 10; j++){
        allFilled &= occupied[i][j];
        allEmpty |= occupied[i][j];
      }
      if (allFilled){
        clearLine(i);
        totalCleared++;
      }
      if (!allEmpty){
        moveDown(i);
      }
    }
    
    // goes to the next level
    linesCleared += totalCleared;
    addPoints(totalCleared);
    /*
    if (onlinePlay && totalCleared != 0){
      attackEnemy = totalCleared;
      send = true;
    }
    */
    if (totalCleared != 0){
      level = (int)((-1 + sqrt(1 + 4*linesCleared))/2); // solves the equation linesCleared = ((level)(level+1))/2
    }
  }
  
}
class Tetrimino {
  // Holds the functions necissary to control the tetrimino
  int blocks[][] = new int[4][2]; // holds the coordinates of each block as [x,y]
  int rotCent[] = new int[2]; // holds the center of rotation
  int startx = 5; // holds the starting x coordinate
  int starty = 0; // holds the starting y coordinate
  boolean wait = false; // holds the falling flag
  int softDrop = 0; // holds the number of blocks the tetrimno fell with a soft drop
  int c; // holds the color of the tetrimino
  boolean hardDrop = false; // holds whether or not the tetrimino fell because of a hardDrop
  int start; // holds the framecount it began at
  int position; // 0 = controlled by player, 1 = next up, 2 = in hold
  int type; // store the type of the tetrimino
  int blockWidth = width/15; // holds the pixel width of each square block
  int gameWidth = blockWidth*10; // holds the length of the borad
  int gameHeight = blockWidth*20; // holds the height of the board

  
  
  Tetrimino(Tetrimino copy, int pos){
    // copies another Tetrimino
    start = frameCount;    
    position = pos;
    this.type = copy.type;
    initialiseBlocks();
  }
  
  Tetrimino(int type, int pos) {
    // creates the tetrimino with the type as a parameter
    start = frameCount;
    position = pos;
    this.type = type;
    initialiseBlocks();
  }
  
  public void initialiseBlocks(){
    // creates the starting position and color of the tetrimino given its type
    switch(type) {
      case 0: //longboy
        for (int i = 0; i < 4; i++) {
          blocks[i][1] = starty + i;
          blocks[i][0] = startx;
        }
        rotCent[0] = startx;
        rotCent[1] = starty +2;
        c = color(52, 120, 229);
        break;
        
      case 1: // squareboy
        for (int i = 0; i < 2; i++) {
          for (int j = 0; j < 2; j++) {
            blocks[j+i*2][1] = starty + j;
            blocks[j+i*2][0] = startx + i;
          }
        }
        rotCent[0] = startx;
        rotCent[1] = starty + 1;
        c = color(242, 213, 53);
        break;
        
      case 2: // L boy
        for (int i = 0; i < 3; i++){
          blocks[i][1] = starty + i;
          blocks[i][0] = startx;
        }
        blocks[3][1] = starty + 2;
        blocks[3][0] = startx + 1;
        
        rotCent[0] = startx;
        rotCent[1] = starty +2;
        
        c = color(255, 119, 15);
        break;
        
      case 3: // reverse L boy
        for (int i = 0; i < 3; i++){
          blocks[i][1] = starty + i;
          blocks[i][0] = startx;
        }
        blocks[3][1] = starty + 2;
        blocks[3][0] = startx - 1;
        
        rotCent[0] = startx;
        rotCent[1] = starty +2;
        
        c = color(25, 66, 132);
        break;
        
      case 4: // left stair boy
        for (int i = 0; i < 2; i++){
          blocks[i][1] = starty + i;
          blocks[i][0] = startx;
        }
        blocks[2][1] = starty;
        blocks[2][0] = startx - 1;
        blocks[3][1] = starty + 1;
        blocks[3][0] = startx + 1;
        
        rotCent[0] = startx;
        rotCent[1] = starty + 1;
        
        c = color(216, 32, 32);
        break;
        
      case 5: // right stair boy
        for (int i = 0; i < 2; i++){
          blocks[i][1] = starty + i;
          blocks[i][0] = startx;
        }
        blocks[2][1] = starty;
        blocks[2][0] = startx + 1;
        blocks[3][1] = starty + 1;
        blocks[3][0] = startx - 1;
        
        rotCent[0] = startx;
        rotCent[1] = starty + 1;
        
        
        c = color(46, 175, 31);
        break;
      case 6: // T boy
        blocks[0][1] = starty;
        blocks[0][0] = startx;
        for (int i = 1; i < 4; i++){
          blocks[i][1] = starty + 1;
          blocks[i][0] = startx - 2 + i;
        }
        
        rotCent[0] = startx;
        rotCent[1] = starty + 1;
        c = color(174, 32, 214);
        break;
    }
  }
  
  public boolean checkIfEnd() {
    // checks if the tetrimino has hit the ground
    for (int[] block : blocks) {
      if (grid.occupied[block[1]+1][block[0]]) {
        if (grid.occupied[0][5] || grid.occupied[1][5]){ // ends the game
          screen = 2;
        }
        return true;
      }
    }
    return false;
  }

  public void makeBlocks() {
    //builds the tetrimino from the blocks given
    if (position == 0){ // if the tetrimino is controlled by the player
      fill(c);
      for (int[] block : blocks) {
        rect(block[0]*blockWidth, block[1]*blockWidth, blockWidth, blockWidth);
      }
    }
    
    if (position == 1){ // if the tetrimino is in the up next block
      fill(c);
      for (int[] block : blocks) {
        rect(block[0]*blockWidth + gameWidth - width*5/24, block[1]*blockWidth + height*23/80, blockWidth, blockWidth);
      }
    }
    
    if (position == 2){ // if the tetrimino is in hold
      fill(c);
      for (int[] block : blocks) {
        rect(block[0]*blockWidth + gameWidth - width*5/24, block[1]*blockWidth + height*11/16, blockWidth, blockWidth);
      }
    }
  }

  public void fall() {
    //moves the tetrimino one step downwards
    if (!fall){ // doesn't fall if the fall flag is set to true
      return;
    }
   
    for (int i = 0; i < 4; i++) {
      blocks[i][1] ++;
    }
    rotCent[1] ++;
  }

  public void makePerminant() {
    //makes the tetrimino part of the board
    for (int[] block : blocks) {
      grid.occupied[block[1]][block[0]] = true;
      grid.colorMap[block[1]][block[0]] = c;
    }
    grid.fixBoard();
    //drop.play();
    
  }

  public void left() {
    //moves the tetrimino left
    //checks if the tetrimino will go offscreen or go into a tetrimino that is placed
    for (int i = 0; i < 4; i++) {
      if (blocks[i][0] - 1 < 0 || grid.occupied[blocks[i][1]][blocks[i][0] - 1]) {
        return;
      }
    }
    for (int i = 0; i < 4; i++) {
      blocks[i][0] --;
    }
    rotCent[0] --;

  }

  public void right() {
    // moves the tetrimino right
    //checks if the tetrimino will go offscreen or go into a tetrimino that is placed
    for (int i = 0; i < 4; i++) {
      if (blocks[i][0] + 1 >= gameWidth/blockWidth || grid.occupied[blocks[i][1]][blocks[i][0]+1]) {
        return;
      }
    }
    for (int i = 0; i < 4; i++) {
      blocks[i][0] ++;
    }
    rotCent[0] ++;

  }

  public void rotate(int direction) { // one is clockwise, negative one is anticlockwise
    // rotates the tetrimino
    // this function ensures the tetrimino doesn't rotate outside the screen or into a placed object
    int distx, disty;
    int distLeft = 0; // holds the max distance outside the screen to the left
    int distRight = 0; // holds the max distance outside the screen to the right
    int[][] temp = copy2d(blocks);
    // multiplies the distance from the center of rotation by the matrix [[0 1][-1 0]] or [[0 -1][1 0]]
    for (int i = 0; i < 4; i++){      
      distx = blocks[i][0] - rotCent[0]; //<>//
      disty = blocks[i][1] - rotCent[1]; //<>//
      temp[i][0] = disty*direction + rotCent[0];
      temp[i][1] = distx *-1*direction + rotCent[1];
      if (0 - temp[i][0] > distLeft){
        distLeft = 0 - temp[i][0];
      }
      if (temp[i][0] - 9 > distRight){
        distRight = temp[i][0] - 9;
      }
    }
    
    // moves the tetrimino back into the screen if it is outside
    for (int i = 0; i < 4; i++){
      temp[i][0] += distLeft - distRight; 
    }
    
    // doesn't rotate the tetrimino if it will go into an occupied space
    for (int i = 0; i < 4; i++){
      if (grid.occupied[temp[i][1]][temp[i][0]]){
        return;
      }
    }
    
    rotCent[0] += distLeft - distRight;
    blocks = copy2d(temp);
  }
  
  public void hardDrop(){
    // immediatly sends a block to the bottom
    if (frameCount - start < 10){ // doesnt allow an immediate drop
      return;
    } 
    int points = 0;
    while(!this.checkIfEnd()){
      this.fall();
      points += 2;
    }
    softDrop += points; // adds double the points for a hard drop
    hardDrop = true;
  }
}
  public void settings() {  fullScreen(); }
}
