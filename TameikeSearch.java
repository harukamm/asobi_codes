// Find a number of tameike.
// tameike and its neighborhood joins together.
import java.io.FileReader;
import java.io.BufferedReader;
import java.util.StringTokenizer;
import java.io.IOException;

public class TameikeSearch {
    static int n = 6;
    static int m = 5;
    static char[][] input = { {'.', '.', 'w', '.', 'w'},
			      {'.', 'w', '.', '.', '.'},
			      {'.', '.', '.', '.', 'w'},
			      {'.', '.', '.', '.', '.'},
			      {'.', '.', '.', '.', 'w'},
			      {',', 'w', '.', 'w', '.'} };
    static boolean [][] checked = new boolean[n][m];

    static boolean kinbo_search(int tate, int yoko) {
	if (tate < 0 || n <= tate ||
	    yoko < 0 || m <= yoko ||
	    input[tate][yoko] != 'w') return false;
	if (!checked[tate][yoko]) {
	    checked[tate][yoko] = true;
	    kinbo_search(tate - 1, yoko);
	    kinbo_search(tate - 1, yoko - 1);
	    kinbo_search(tate - 1, yoko + 1);
	    kinbo_search(tate, yoko - 1);
	    kinbo_search(tate, yoko + 1);
	    kinbo_search(tate + 1, yoko);
	    kinbo_search(tate + 1, yoko - 1);
	    kinbo_search(tate + 1, yoko + 1);
	    return true;
	}
	return false;
    }

    public static void main(String args[]) {
	// initialize ans
	for (int i = 0; i < n; i++) {
	    for (int j = 0; j < m; j++) {
		checked [i][j] = false;
	    }
	}
	int tameike = 0;
	for (int i = 0; i < n; i++) {
	    for (int j = 0; j < m; j++) {
		if(kinbo_search(i, j))
		    tameike ++;
	    }
	}
	System.out.println("the number of tameike is " + tameike + "\n");
    }
}
