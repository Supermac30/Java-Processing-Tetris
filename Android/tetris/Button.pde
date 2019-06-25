class Button{
  // makes the UI much easier to work with
  float buttonX; // holds the x coordinate of the button
  float buttonY; // holds the y coordinate of the button
  float buttonWidth; // holds the width of the button
  float buttonHeight; // holds the height of the button
  String text; // holds the text within the button
  color fill = color (0,0,0); // holds the color of the button
  color outline = color (255,255,255); // holds the color of the outline of the button
  color textColor =  color (255,255,255); // holds the color of the text
  boolean locked = false; // holds whether or not the button can currently be used
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
  
  boolean isHover(){
    // returns whether or not the button is hovered over
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight){
        return true;
    }
    return false;
  }
}
