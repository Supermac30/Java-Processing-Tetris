/* @author Mark Bedaywi
 * This is a version of Tetris for my 11U CPT
 * 
 * A Tetrimino is the name of a block in Tetris, it is made up of four blocks and is connected othogonally
 * A line is cleared there is no empty space
 * A line is moved down if there is only empty space under it
 * To ensure no piece drought every piece will come once every 7 times
 */
 
import processing.sound.*;
import java.util.Arrays;
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

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

int score = 0; // holds the players score
int blockWidth = 40; // holds the pixel width of each square block
int gameWidth = blockWidth*10; // holds the length of the borad
int gameHeight = blockWidth*20; // holds the height of the board
int amount = 7; // holds the amount of tetrimino types
boolean occupied[][] = new boolean[21][10]; // stores all the currently occupied blocks
color colorMap[][] = new color[20][10]; // stores the color of all the occupied blocks
boolean fall = true; // holds whether or not the tetrimino should fall
int time = 31; // holds the time since the tetrimino hit a surface
int level = 0; // holds the level currently on
int screen = 0; // holds the screen you are currently on
int linesCleared = 0; // holds the number of lines cleared
boolean pressedHold = false; // holds whether or not hold has been pressed this round
int[] nextTetrimino = {-1,0,0,0,0,0,0,-1}; // holds the values of the next seven tetriminos
int randomLoc; // holds the random location that will be given out
int rand; // holds the random value that will be returned by chooseNext()
Tetrimino boy = new Tetrimino(chooseNext(), 0); // holds the tetrimino currently falling
int upNext = chooseNext(); // holds the identity of the tetrimino coming up next
Tetrimino nextBoy = new Tetrimino(upNext, 1); // holds the tetrimino that will come up next
Tetrimino hold; // holds the tetrimino in hold
Tetrimino temp; // is a temporary tetrimino for switching boy and hold
int difficulty = 50; // holds the difficulty of the game

Button startButton = new Button(100, 150, 400, 100, "Single Player");
Button hostServer = new Button(100, 300, 200, 100, "Host Server");
Button joinServer = new Button(300, 300, 200, 100, "Join Server");
Button settingsButton = new Button(100, 450, 400, 100, "Settings");
Button exitButton = new Button(100, 600, 400, 100, "Quit");

Button enableController = new Button(100,100,400,100, "Enable controller");
Button setDifficulty = new Button(100, 250, 400, 100, "Difficulty: " + difficulty);
Button setSensitivity = new Button(100, 400, 400, 100, "Controller Sensitivity: "+ (10-wait));
Button returnToMenu = new Button(100, 550, 400, 100, "Return to the menu");

boolean controller = false; // holds whether or not you are playing with a compatable controller

class Button{
  // makes the UI much easier to work with
  float buttonX; // holds the x coordinate of the button
  float buttonY; // holds the y coordinate of the button
  float buttonWidth; // holds the width of the button
  float buttonHeight; // holds the height of the button
  String text; // holds the text within the button
  color fill = color (0,0,0); // holds the color of the button
  color outline = color (255,255,255); // holds the color of the outline of the button
  color textColor =  color (255,255,255);
  int textSize = 20;
  Button(float buttonX, float buttonY, float buttonWidth, float buttonHeight, String text){
    // button constructor
    this.buttonX = buttonX;
    this.buttonY = buttonY;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.text = text;
  }
  void buildButton(){
    // creates the button
    fill(fill);
    stroke(outline);
    textSize(textSize);
    rect(buttonX,buttonY,buttonWidth,buttonHeight);
    fill(textColor);
    text(text, buttonX+(buttonWidth*0.5) - text.length()*4.5, buttonY+(buttonHeight*0.5) + (0.2*textSize));
  }
  boolean isPressed(){
    // returns whether or not the button has been pressed
    if (mousePressed){
      if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight){
        return true;
      }
    }
    return false;  
  }
  
  boolean isHover(){
    // returns whether or not the button is hovered over
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY > buttonY + buttonHeight){
        return true;
    }
    return false;
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
  color c; // holds the color of the tetrimino
  boolean hardDrop = false; // holds whether or not the tetrimino fell because of a hardDrop
  int start; // holds the framecount it began at
  int position; // 0 = controlled by player, 1 = next up, 2 = in hold
  int type; // store the type of the tetrimino
  
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
  
  void initialiseBlocks(){
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
  boolean checkIfEnd() {
    //checks if the tetrimino has hit the ground
    for (int[] block : blocks) {
      if (occupied[block[1]+1][block[0]]) {
        if (occupied[0][5]){ // ends the game
          screen = 2;
        }
        return true;
      }
    }
    return false;
  }

  void makeBlocks() {
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
        rect(block[0]*blockWidth + gameWidth - 125, block[1]*blockWidth + 230, blockWidth, blockWidth);
      }
    }
    
    if (position == 2){ // if the tetrimino is in hold
      fill(c);
      for (int[] block : blocks) {
        rect(block[0]*blockWidth + gameWidth - 125, block[1]*blockWidth + 550, blockWidth, blockWidth);
      }
    }
  }

  void fall() {
    //moves the tetrimino one step downwards
    if (!fall){ // doesn't fall if the fall flag 
      return;
    }
   
    for (int i = 0; i < 4; i++) {
      blocks[i][1] ++;
    }
    rotCent[1] ++;
    softDrop++;
  }

  void makePerminant() {
    //makes the tetrimino part of the board
    for (int[] block : blocks) {
      occupied[block[1]][block[0]] = true;
      colorMap[block[1]][block[0]] = c;
    }
    fixBoard();
    drop.play();
  }

  void left() {
    //moves the tetrimino left
    //checks if the tetrimino will go offscreen or go into a tetrimino that is placed
    for (int i = 0; i < 4; i++) {
      if (blocks[i][0] - 1 < 0 || occupied[blocks[i][1]][blocks[i][0] - 1]) {
        return;
      }
    }
    for (int i = 0; i < 4; i++) {
      blocks[i][0] --;
    }
    rotCent[0] --;

  }

  void right() {
    // moves the tetrimino right
    //checks if the tetrimino will go offscreen or go into a tetrimino that is placed
    for (int i = 0; i < 4; i++) {
      if (blocks[i][0] + 1 >= gameWidth/blockWidth || occupied[blocks[i][1]][blocks[i][0]+1]) {
        return;
      }
    }
    for (int i = 0; i < 4; i++) {
      blocks[i][0] ++;
    }
    rotCent[0] ++;

  }

  void rotate(int direction) { // one is clockwise, negative one is anticlockwise
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
      if (occupied[temp[i][1]][temp[i][0]]){
        return;
      }
    }
    
    rotCent[0] += distLeft - distRight;
    blocks = copy2d(temp);
  }
  
  void hardDrop(){
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

void createGame() {
  // creates the background
  background(211, 211, 211);
  for (int i = 0; i <= gameWidth; i += blockWidth) {
    line(i, 0, i, gameHeight);
  }
  for (int i = 0; i <= gameHeight; i += blockWidth) {
    line(0, i, gameWidth, i);
  }

  textSize(32);
  // place all outside board elements gameWidth+10 away
  fill(0,0,0);
  text("score: "+score, gameWidth+10, 36);
  text("level: "+level,gameWidth+10,36+50);
  text("next block", gameWidth+10, 36+150);
  rect(gameWidth+10, 36+180, 180, 180);
  text("hold", gameWidth+10, 500);
  fill(255,255,255);
  rect(gameWidth+10, 500+36, 180, 180);

  // builds all blocks in occupied
  for (int i = 0; i < 20; i++) {
    for (int j = 0; j < 10; j++) {
      if (occupied[i][j]) {
        fill(colorMap[i][j]);
        rect(j*blockWidth, i*blockWidth, blockWidth, blockWidth);
      }
    }
  }
}

int[][] copy2d(int array2d[][]){
  // Copies a 2d array, why isn't this built into java?
  int temp[][] = new int[array2d.length][array2d[0].length];
  for (int i = 0; i < array2d.length; i++){
    for (int j = 0; j < array2d[i].length; j++){
      temp[i][j] = array2d[i][j];
    }
  }
  return temp;
}

int chooseNext(){
  // chooses the next 7 tetriminos that are all different in random order.
  // If the next 7 tetriminos are already chosen, -1 didn't reach index 0 the next index is returned and all numbers are moved back.
  // To put the numbers from 0 to 6 in random order an algorithm close to shuffling cards is used, where a random index is taken out and another index is chosen from a smaller arraylist.

  if (nextTetrimino[0] == -1){
    ArrayList<Integer> values = new ArrayList<Integer> (Arrays.asList(0,1,2,3,4,5,6));
    for (int i = 0; i < amount; i++){
      randomLoc = (int) random(0,amount-i);
      nextTetrimino[i] = values.get(randomLoc);
      values.remove(randomLoc);
    }
    nextTetrimino[7] = -1;
  }
  rand = nextTetrimino[0];
  for (int i = 0; i < amount; i ++){
    nextTetrimino[i] = nextTetrimino[i+1];
  }
  return rand;
}

void moveDown(int lineNum){
  //moves down all blocks starting from lineNum
  for (int i = lineNum; i > 0; i--){
    occupied[i] = occupied[i-1].clone();
    colorMap[i] = colorMap[i-1].clone();
  }
}

void clearLine(int lineNum){
  //clears the line lineNum
  for (int i = 0; i < 10; i++){
    occupied[lineNum][i] = false;
  }
  clear.play();
  moveDown(lineNum);
}

void fixBoard(){
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
  if (totalCleared != 0){
    level = (int)((-1 + sqrt(1 + 4*linesCleared))/2); // solves the equation linesCleared = ((level)(level+1))/2
  }
}

void addPoints(int linesCleared){
  // adds points depending on the number of lines cleared
  switch(linesCleared){
    case 1:
      score += 40 * (level+1);
      break;
    case 2:
      score += 100 * (level+1);
      break;
    case 3:
      score += 300 * (level+1);
      break;
    case 4:
      score += 1200 * (level+1);
      break;
  }
  score += boy.softDrop; // adds points for the drop

}

void hold(){
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

void gameScreen(){
  // holds the game screen
  createGame();
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
  if (frameCount % ceil(60 / pow(1 + difficulty/100 ,level))  == 0) {
    boy.fall();
  }
  
}

void gameOverScreen(){
  // comes up when the player loses //<>//
  background(0);
  text("gameover",width/2,height/2);
}

void settingsScreen(){
  background(100,100,100);
  if (controller){
    enableController.text = "Disable Controller";
  }
  else{
    enableController.text = "Enable Controller";
  }
  textSize(15);
  text("Remember to connect your controller before opening the file",80,215);
  
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

void menuScreen(){
  // Is the menu that first comes up 
  background(100,100,100);
  textSize(64);
  text("Tetris",width/2 - 100, 100);
  startButton.buildButton();
  settingsButton.buildButton();
  hostServer.buildButton();
  joinServer.buildButton();
  exitButton.buildButton();
  
  
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

void setup() {
  //runs once
  size(600, 800);
}

void gameSetup(){
  // setups up the game
  
  //initialises occupied blocks
  for (int i = 0; i<19; i++) {
    for (int j = 0; j<10; j++) {
      occupied[i][j] = false;
    }
  }
  for (int i = 0; i<10; i++) {
    occupied[20][i] = true;
  }
 
  // plays the song
  path = sketchPath(musicName);
  music = new SoundFile(this, path);
  music.loop();
  
  //sets up the sound effects
  path = sketchPath(clearName);
  clear = new SoundFile(this, path);
  path = sketchPath(dropName);
  drop = new SoundFile(this, path);
  
  screen = 1;
}

void controllerSetup(){
  //connects to controller - remember to connect control before starting sketch
  control = ControlIO.getInstance(this);
  if (stick == null){
    stick = control.getMatchedDevice("PS1Classic");
  }
  if (stick == null){
    println("no recognised controller connected");
  }
}

void loadingScreen(){
  // makes a loading screen
  background(255,255,255);
  fill(0);
  textSize(20);
  text("Please wait, loading...", 200, 100);
  if (!controller){
    text("Keyboard Controls:", 20, 200);
    text("- Arrow keys for movement", 40, 250);
    text("- A and D for rotation", 40, 300);
    text("- W to hold", 40, 350);
  }
  screen = 4;
}

void draw() {
  //loops
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
  }
}

void controllerInput(){
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
    if (X > 0.5){
      boy.right();
    }
    if (X < -0.5){
      boy.left();
    }
    if (Y > 0.5 ){
      boy.fall();
    }
    if (Y < -0.5 ){
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

void keyPressed() {
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
