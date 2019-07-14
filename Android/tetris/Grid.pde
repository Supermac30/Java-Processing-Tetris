class Grid{
  int score = 0; // holds the players score
  int blockWidth = width/15; // holds the pixel width of each square block
  int gameWidth = blockWidth*10; // holds the length of the borad
  int gameHeight = blockWidth*20; // holds the height of the board
  boolean occupied[][] = new boolean[21][10]; // stores all the currently occupied blocks
  color colorMap[][] = new color[20][10]; // stores the color of all the occupied blocks
  int level = 0; // holds the level currently on
  
  boolean send = false; // holds whether or not a packet should be sent
  
  Grid(){}
  
  void createGame() {
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
    text("hold", gameWidth+10, height*11/20);
    fill(255,255,255);
    rect(gameWidth+width/60, height*12/20, width*3/10, width*3/10);
  
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

  void attacked(int lines){
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
  
  void moveUp(){
    // moves up all the blocks
    for (int i = 0; i < 20; i++){
      this.occupied[i] = occupied[i+1].clone();
      this.colorMap[i] = colorMap[i+1].clone();
    }
  }
  
  void moveDown(int lineNum){
    //moves down all blocks starting from lineNum
    for (int i = lineNum; i > 0; i--){
      this.occupied[i] = occupied[i-1].clone();
      this.colorMap[i] = colorMap[i-1].clone();
    }
  }
  
  void clearLine(int lineNum){
    //clears the line lineNum
    for (int i = 0; i < 10; i++){
      this.occupied[lineNum][i] = false;
    }
    //clear.play();
    this.moveDown(lineNum);
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
