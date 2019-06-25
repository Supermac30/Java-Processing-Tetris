/*  
 * @author Mark Bedaywi
 * This is a version of Tetris for my 11U CPT
 * 
 * A Tetrimino is the name of a block in Tetris, it is made up of four blocks and is connected othogonally
 * A line is cleared there is no empty space
 * A line is moved down if there is only empty space under it
 * To ensure no piece drought every piece will come once every 7 times
 */
 
import cassette.audiofiles.SoundFile;
import java.util.Arrays;
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
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

Grid grid; // holds the grid that will be used

Button startButton = new Button(100, 150, 400, 100, "Single Player");
Button hostServer = new Button(100, 300, 200, 100, "Host Server");
Button joinServer = new Button(300, 300, 200, 100, "Join Server");
Button settingsButton = new Button(100, 450, 400, 100, "Settings");
Button exitButton = new Button(100, 600, 400, 100, "Quit");
Button enableController = new Button(100,100,400,100, "Enable controller");
Button setDifficulty = new Button(100, 400, 400, 100, "Difficulty: " + difficulty);
Button setSensitivity = new Button(100, 250, 400, 100, "Controller Sensitivity: "+ (10-wait));
Button returnToMenu = new Button(100, 550, 400, 100, "Return to the menu");
Button returnGameover = new Button(100, 400, 400, 100, "Return to the menu");

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
int[][] copy2d(int array2d[][]){
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

int chooseNext(){
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

void addPoints(int linesCleared){
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

void gameOverScreen(){ 
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

void settingsScreen(){
  background(100,100,100);
  if (controller){
    enableController.text = "Disable Controller";
    setSensitivity.locked = false;
  }
  else{
    enableController.text = "Enable Controller";
    setSensitivity.locked = true;
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

void hostScreen(){
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

void joinScreen(){
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

void setup() {
  //runs once
  frameRate(30);
  fullScreen();
}

void gameSetup(){
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
    text("- Left and Right for movement", 40, 250);
    text("- Up for a Hard Drop", 40, 300);
    text("- Down for a Soft Drop", 40, 350);
    text("- A and D for rotation", 40, 400);
    text("- W to hold", 40, 450);
  }
  screen = 4;
}

void draw() {
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
void mousePressed(){
  // works with the touchInput function to take touch input
  startPress[0] = mouseX;
  startPress[1] = mouseY;
  startPress[2] = frameCount;
  if (screen == 1){
    if (mouseX > grid.gameWidth+10 && mouseX < grid.gameWidth+180 && mouseY > 536 && mouseY < 716){
      hold();
    }
  }
}
void touchInput(){
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
      boy.softDrop++;
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
