class Grid{
  int score = 0; // holds the players score
  int blockWidth = 40; // holds the pixel width of each square block
  int gameWidth = blockWidth*10; // holds the length of the borad
  int gameHeight = blockWidth*20; // holds the height of the board
  boolean occupied[][] = new boolean[21][10]; // stores all the currently occupied blocks
  color colorMap[][] = new color[20][10]; // stores the color of all the occupied blocks
  int level = 0; // holds the level currently on
  
  Grid(){}
  
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
    
    if (onlinePlay){
      println("Playing online");
      if (isServer){
        if (client != null){
          try{
            String[] received = client.readString().split(" ");
            enemyScore = parseInt(received[0]);
            attacked(parseInt(received[1]));
          } catch(Exception e){}
        }
        server.write(score + " " + attackEnemy);
      } else {
        client.write(score + " " + attackEnemy);
        if (client.available() > 0){
          try{
            String[] received = client.readString().split(" ");
            enemyScore = parseInt(received[0]);
            attacked(parseInt(received[1]));
          } catch(Exception e){}
        }
      }
    }
  }

  void attacked(int lines){
    // adds a line when you get attacked
    println("oh no" + lines);
    for (int i = 0; i < lines; i++){
      int place = (int)random(0,11);
      moveUp();
      for (int j = 0; j < 10; j++){
        if (j == place){
          continue;
        }
        occupied[0][j] = true;
        colorMap[0][j] = color(211,211,211);
      }
    }
  }
  
  void moveUp(){
    // moves up all the blocks
    for (int i = 20; i > 0; i--){
      occupied[i] = occupied[i+1].clone();
      colorMap[i] = colorMap[i+1].clone();
    }
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
    //clear.play();
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
    if (onlinePlay){
      attackEnemy = totalCleared;
    }
    if (totalCleared != 0){
      level = (int)((-1 + sqrt(1 + 4*linesCleared))/2); // solves the equation linesCleared = ((level)(level+1))/2
    }
  }
  
}
