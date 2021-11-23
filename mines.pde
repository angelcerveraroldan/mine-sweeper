Tile[] board_tiles;

boolean lost = false;
boolean hard_mode = false;

// Hard mode is an 18 * 18 tile board, easy mode is a 9 * 9 tile game
int total_tiles = hard_mode ? 25 : 18; // MAX 20!!
int bomb_count = total_tiles + 5;

// TODO: This two arrays should really be related
int[] bomb_x_coord = new int[bomb_count];
int[] bomb_y_coord = new int[bomb_count];

void setup() {
    size(800, 800);

    board_tiles = new Tile[(int) Math.pow(total_tiles, 2)];

    // Generate coordinates for the bombs
    for (int i = 0; i < bomb_count; i++) {
        // TODO: The same (x, y) coordinate could be generated twice, this would result in as little as 1 bomb in the entire map
        // but the odds of that happening are small, so this error doesn't need to be fixed right away
        int rand_x_coord = int(random(0, total_tiles));
        int rand_y_coord = int(random(0, total_tiles));

        bomb_x_coord[i] = rand_x_coord;
        bomb_y_coord[i] = rand_y_coord;
    }
    
    // Make the board
    int tile_index = 0;

    for (int vertical = 0; vertical < total_tiles; vertical++) {
        for (int horizontal = 0; horizontal < total_tiles; horizontal ++) {
            boolean is_bomb_coordinate = false;

            // Check if bomb_x_coord[n] = horizontal and bomb_y_coord[n] = vertical
            // Check if the tile should be a bomb
            if (bomb_check(bomb_x_coord, horizontal, bomb_y_coord, vertical)) {
                is_bomb_coordinate = true;
            } 

            board_tiles[tile_index++] = new Tile(vertical * (width / total_tiles), horizontal * (width / total_tiles), is_bomb_coordinate);
        }
    }
    
    // Find the number of bombs surrounding each tiles
    for (int i = 0; i < Math.pow(total_tiles, 2); i++) {
        if (board_tiles[i].bomb) {
            count_around(i);
        }
    }
}

void draw () {
    // Display the board
    for (Tile tile : board_tiles) {
        tile.display(width, (float) total_tiles, lost);
    }
}

// TODO: Change the way we check if a tile should or shouln't be a bomb, as it is very inefficient
boolean bomb_check (int[] x_arr, int x, int[] y_arr, int y) {
    int arr_len = x_arr.length;
    
    for (int i = 0; i < arr_len; i++) {
        if ( y_arr[i] == y && x_arr[i] == x ) {
            return true;
        }
    }

    return false;
}

// Click on what you think isnt a bomb
void mouseClicked () {
    // Save the coordinate of the mouse when it clicks
    int x_clicked = (int) (mouseX / (width / total_tiles));
    int y_clicked = (int) (mouseY / (width / total_tiles));

    int tile_index = (total_tiles * x_clicked) + y_clicked;
    
    if (tile_index > Math.pow(total_tiles, 2)) {
        return;
    }

    if (mouseButton == LEFT) {
        // Mark as not bomb when the user left clicks on square
        // If this returns true, it means the user clicked on a bomb, game should be over
        lost = board_tiles[tile_index].is_safe();

        // TODO: Make a function that will click in all surrounding tiles if the tile being clicked on has a surrounding bomb count of 0 (recursive function?)
        board_tiles[tile_index].marked_safe = true;  

        if (board_tiles[tile_index].touching_bomb_count == 0) {
            click_around(tile_index);
        }
    } else if (mouseButton == RIGHT) {
        // Mark as bomb when the user right clicks on square
        board_tiles[tile_index].marked_as_bomb = !board_tiles[tile_index].marked_as_bomb;
    }
}

// Only works for surrounded tiles atm
void click_around (int index) {
    boolean above = (index % total_tiles != 0);
    boolean below = (index % total_tiles != (total_tiles - 1));

    boolean right = (index < (Math.pow(total_tiles, 2) - total_tiles));
    boolean left = (index > (total_tiles - 1));

    // -1 is up
    // + 1 is down

    // + tiles is right
    // - tiles is left

    if (left) {
        board_tiles[index - total_tiles].marked_safe = true;  
        
        if (above) {
            board_tiles[(index - total_tiles) - 1].marked_safe = true;
        }
        if (below) {
            board_tiles[(index - total_tiles) + 1].marked_safe = true;
        }
    }

    if (right) {
        board_tiles[index + total_tiles].marked_safe = true;  

        if (above) {
            board_tiles[(index + total_tiles) - 1].marked_safe = true;
        }
        if (below) {
            board_tiles[(index + total_tiles) + 1].marked_safe = true;
        }
    }

    if (below)  {
        board_tiles[index + 1].marked_safe = true;
    }

    if (above) {
        board_tiles[index - 1].marked_safe = true;
    }
}

// Try to pass a function as a parameter to the following function, and make the function run that parameter in all existing surrounding boxes

// Once the array has been made, count the ammount of bombs surrounding 
void count_around (int tile_index) {
    boolean above = (tile_index % total_tiles != 0);
    boolean below = (tile_index % total_tiles != (total_tiles - 1));

    boolean right = (tile_index < (Math.pow(total_tiles, 2) - total_tiles));
    boolean left = (tile_index > (total_tiles - 1));

    // If the bomb is not on the top row, it should add a bomb count to the tile above it
    if (above) {
        board_tiles[tile_index - 1].neighbour_inc();

        if (right) {
            board_tiles[(tile_index - 1) + total_tiles].neighbour_inc();
        }

        if (left) {
            board_tiles[(tile_index - 1) - total_tiles].neighbour_inc();
        }
    }

    // If the bomb is not on the bottom row, it should have a tile below it
    if (below) {
        board_tiles[tile_index + 1].neighbour_inc();

        if (right) {
            board_tiles[(tile_index + 1) + total_tiles].neighbour_inc();
        }

        if (left) {
            board_tiles[(tile_index + 1) - total_tiles].neighbour_inc();
        }
    }

    //Should have a tile to the right
    if (right) {
        board_tiles[tile_index + total_tiles].neighbour_inc();
    }

    //Should have a tile to the left
    if (left) {
        board_tiles[tile_index - total_tiles].neighbour_inc(); // Seems to be running for 80
    }
}


// Function to check if an array contains an integer
// NO GENERICS IN PROCESSING :(
boolean array_contains(int[] arr, int find) {
    for (int num : arr) {
        if (num == find) {
            return true;
        }
    }

    return false;
}