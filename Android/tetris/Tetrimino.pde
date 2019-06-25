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
  int blockWidth = width/20; // holds the pixel width of each square block\
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
    if (!fall){ // doesn't fall if the fall flag is set to true
      return;
    }
   
    for (int i = 0; i < 4; i++) {
      blocks[i][1] ++;
    }
    rotCent[1] ++;
  }

  void makePerminant() {
    //makes the tetrimino part of the board
    for (int[] block : blocks) {
      grid.occupied[block[1]][block[0]] = true;
      grid.colorMap[block[1]][block[0]] = c;
    }
    grid.fixBoard();
    //drop.play();
    
  }

  void left() {
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

  void right() {
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
      if (grid.occupied[temp[i][1]][temp[i][0]]){
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
