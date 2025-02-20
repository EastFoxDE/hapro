////////////////////////////////////////////////////

/*  Some values are modifiable, see settings.txt  */

/*        DO NOT MODIFY BEYOND THIS POINT!        */

////////////////////////////////////////////////////

#include <stdio.h>
#include <omp.h>
#include <SDL2/SDL.h>
#include <math.h>
#include <unistd.h>
#include <ctype.h>

//Initialization
int threads;
long double colorMulti = 1.0;
int viewSequence;
float zoom;
float zoomInPercent;
int depth;
int max;
int width;
int height;
long double offset_Re;
long double offset_Im;

//Chat-GPT functions for reading the values from the settings.txt, see end of code
char *trimWhitespace(char *str);
void loadSettings(const char *filename);

//Color a specific pixel
void putPixel(SDL_Surface *surface, int X, int Y, int color) {
	unsigned char *scr = (unsigned char *)(surface->pixels);
	scr += Y * surface->pitch + X * 4;
	*((unsigned int *)scr) = color;
}

//Magic :-)
//Check if complex num is part of Mandelbrot (|zn| > 4)
unsigned int checkMandelbrot(long double Re, long double Im){
	long double zn_absolut = 0.0L, zn_Re = 0.0L, zn_Im = 0.0L;
	long double temp = 0.0L;

	//Check if in bulb 1 or 2, see https://iquilezles.org/articles/mset1bulb/
	zn_absolut = sqrtl(zn_Re*zn_Re + zn_Im*zn_Im);
	temp = zn_absolut*zn_absolut;
	/*if((256 * temp * temp - 96 * temp + 32 * zn_Re - 3) < 0.0){
		return 255;
	}*/
	/*else if((4*(zn_absolut+1)*(zn_absolut+1)-1) < 0.0){
		return 255;
	}*/

	// i = 0 is skipped, because z0 = 0
	for(unsigned int i=1; i<=depth; i++){
		//Calculate new value of complex num
		temp = (zn_Re*zn_Re) - (zn_Im*zn_Im) + Re;
		zn_Im = 2.0L*zn_Re*zn_Im + Im;
		zn_Re = temp;

		//Calculate absolute
		zn_absolut = sqrtl(zn_Re*zn_Re + zn_Im*zn_Im);

		//Check if Mandelbrot-Criteria is met
		if(zn_absolut > 2.0L){
			return (unsigned int)(i*colorMulti);
		}
	}
	//if not in mandelbrot, return color black
	return 255;
}

int main(int argc, char** argv) {

	//Color scheme
	unsigned int palette[256] = {
    		0xFF00007F, 0xFF000087, 0xFF00008F, 0xFF000097, 0xFF00009F, 0xFF0000A7, 0xFF0000AF, 0xFF0000B7,
    		0xFF0000BF, 0xFF0000C7, 0xFF0000CF, 0xFF0000D7, 0xFF0000DF, 0xFF0000E7, 0xFF0000EF, 0xFF0000F7,
    		0xFF0000FF, 0xFF0010FF, 0xFF0020FF, 0xFF0030FF, 0xFF0040FF, 0xFF0050FF, 0xFF0060FF, 0xFF0070FF,
    		0xFF0080FF, 0xFF0090FF, 0xFF00A0FF, 0xFF00B0FF, 0xFF00C0FF, 0xFF00D0FF, 0xFF00E0FF, 0xFF00F0FF,
    		0xFF00FFFF, 0xFF10FFEF, 0xFF20FFDF, 0xFF30FFCF, 0xFF40FFBF, 0xFF50FFAF, 0xFF60FF9F, 0xFF70FF8F,
    		0xFF80FF7F, 0xFF90FF6F, 0xFFA0FF5F, 0xFFB0FF4F, 0xFFC0FF3F, 0xFFD0FF2F, 0xFFE0FF1F, 0xFFF0FF0F,
    		0xFFFFFF00, 0xFFFFEF00, 0xFFFFDF00, 0xFFFFCF00, 0xFFFFBF00, 0xFFFFAF00, 0xFFFF9F00, 0xFFFF8F00,
			0xFFFF7F00, 0xFFFF6F00, 0xFFFF5F00, 0xFFFF4F00, 0xFFFF3F00, 0xFFFF2F00, 0xFFFF1F00, 0xFFFF0F00,
    		0xFFFF0000, 0xFFEF0000, 0xFFDF0000, 0xFFCF0000, 0xFFBF0000, 0xFFAF0000, 0xFF9F0000, 0xFF8F0000,
    		0xFF7F0000, 0xFF6F0000, 0xFF5F0000, 0xFF4F0000, 0xFF3F0000, 0xFF2F0000, 0xFF1F0000, 0xFF0F0000,
    		0xFFFF7F00, 0xFFFF8700, 0xFFFF8F00, 0xFFFF9700, 0xFFFF9F00, 0xFFFFA700, 0xFFFFAF00, 0xFFFFB700,
    		0xFFFFBF00, 0xFFFFC700, 0xFFFFCF00, 0xFFFFD700, 0xFFFFDF00, 0xFFFFE700, 0xFFFFEF00, 0xFFFFF700,
    		0xFFFFFF00, 0xFFEFFF10, 0xFFDFDF20, 0xFFCFCF30, 0xFFBFBF40, 0xFFAFB050, 0xFF9FA060, 0xFF8F9070,
    		0xFF7F8080, 0xFF6F7090, 0xFF5F60A0, 0xFF4F50B0, 0xFF3F40C0, 0xFF2F30D0, 0xFF1F20E0, 0xFF0F10F0,
    		0xFF0010FF, 0xFF001FFF, 0xFF002FFF, 0xFF003FFF, 0xFF004FFF, 0xFF005FFF, 0xFF006FFF, 0xFF007FFF,
    		0xFF008FFF, 0xFF009FFF, 0xFF00AFFF, 0xFF00BFFF, 0xFF00CFFF, 0xFF00DFFF, 0xFF00EFFF, 0xFF00FFFF,
    		0xFF10FFEF, 0xFF20FFDF, 0xFF30FFCF, 0xFF40FFBF, 0xFF50FFAF, 0xFF60FF9F, 0xFF70FF8F, 0xFF80FF7F,
    		0xFF90FF6F, 0xFFA0FF5F, 0xFFB0FF4F, 0xFFC0FF3F, 0xFFD0FF2F, 0xFFE0FF1F, 0xFFF0FF0F, 0xFFFF0000,
    		0xFFEF0000, 0xFFDF1000, 0xFFCF2000, 0xFFBF3000, 0xFFAF4000, 0xFF9F5000, 0xFF8F6000, 0xFF7F7000,
    		0xFF6F8000, 0xFF5F9000, 0xFF4FA000, 0xFF3FB000, 0xFF2FC000, 0xFF1FD000, 0xFF0FE000, 0xFF00F000,
    		0xFF0000FF, 0xFF0010FF, 0xFF0020FF, 0xFF0030FF, 0xFF0040FF, 0xFF0050FF, 0xFF0060FF, 0xFF0070FF,
    		0xFF0080FF, 0xFF0090FF, 0xFF00A0FF, 0xFF00B0FF, 0xFF00C0FF, 0xFF00D0FF, 0xFF00E0FF, 0xFF00F0FF,
    		0xFF00FFFF, 0xFF10FFF0, 0xFF20FFE0, 0xFF30FFD0, 0xFF40FFC0, 0xFF50FFB0, 0xFF60FFA0, 0xFF70FF90,
    		0xFF80FF80, 0xFF90FF70, 0xFFA0FF60, 0xFFB0FF50, 0xFFC0FF40, 0xFFD0FF30, 0xFFE0FF20, 0xFFF0FF10,
    		0xFFFF0000, 0xFFF00010, 0xFFE00020, 0xFFD00030, 0xFFC00040, 0xFFB00050, 0xFFA00060, 0xFF900070,
    		0xFF800080, 0xFF700090, 0xFF6000A0, 0xFF5000B0, 0xFF4000C0, 0xFF3000D0, 0xFF2000E0, 0xFF1000F0,
    		0xFF000000, 0xFF010101, 0xFF020202, 0xFF030303, 0xFF040404, 0xFF050505, 0xFF060606, 0xFF070707
	};

	//Read values
	loadSettings("mandelbrot_settings.txt");

	//Make sure that the iteration-depth meets the color scheme to prevent segmenation fault
	colorMulti = 256 / (float)depth;

	//Calculate where the axis are
	int Re_axis = width/2+100;
	int Im_axis = height/2;

	//Track iterations
	int run = 1;

	//SDL initialization
	SDL_Event event;
	SDL_Window *window = NULL;
	SDL_Renderer *renderer = NULL;
	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        	printf("SDL could not initialize! SDL Error: %s\n", SDL_GetError());
        	return 0;
	}
    	window = SDL_CreateWindow("Mandelbrot Set", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_SHOWN);
    	if (!window) {
        	printf("Window could not be created! SDL Error: %s\n", SDL_GetError());
	        SDL_Quit();
        	return 0;
    	}
    	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    	if (!renderer) {
        	printf("Renderer could not be created! SDL Error: %s\n", SDL_GetError());
	        SDL_DestroyWindow(window);
	        SDL_Quit();
	        return 0;
	}

	SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
	SDL_RenderClear(renderer);
	SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
   	for (int i = 0; i < width; ++i)
        	SDL_RenderDrawPoint(renderer, i, i);
    	SDL_RenderPresent(renderer);
    	SDL_Surface *surface = SDL_GetWindowSurface(window);

	//Set the number of threads
	omp_set_num_threads(threads);

	//Init for window title
        char buf[100];
        SDL_SetWindowTitle(window, buf);
        int ticks = SDL_GetTicks();

	//Endless loop until max iterations is hit
	while (1) {
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        	SDL_RenderClear(renderer);
        	SDL_LockSurface(surface);

		//Here is where the magic happens :-)
		//#pragma omp parallel for default(shared) schedule(dynamic, 10) 
		#pragma omp parallel for collapse(2) schedule(guided)
		for(int x=0; x<width-1; x++){
			for(int y=0; y<height-1; y++){
				long double Re = ((long double)(x-Re_axis))/zoom + offset_Re;
				long double Im = ((long double)(y-Im_axis))/zoom + offset_Im;
				putPixel(surface, x, y, palette[checkMandelbrot(Re, Im)]);
			}
		}

		SDL_UnlockSurface(surface);
       		SDL_UpdateWindowSurface( window );

		//Change the window title
		sprintf(buf, "Run: %i  Time: %dms", run, SDL_GetTicks()-ticks);
                SDL_SetWindowTitle(window, buf);

		//View the first sequence and last sequence for longer
		if(run == 1){
			sprintf(buf, "WAITING (%d seconds) Run: %i  Time: %dms", viewSequence/1000, run, SDL_GetTicks()-ticks);
                        SDL_SetWindowTitle(window, buf);
			usleep(viewSequence*1000);
		} else if(run == max){
			sprintf(buf, "FINISHED Run: %i  Time: %dms", run, SDL_GetTicks()-ticks);
                	SDL_SetWindowTitle(window, buf);
			break;
		}

		//Zoom more in
		zoom *= (1+(zoomInPercent/100));
		run++;
		ticks = SDL_GetTicks();

		if (SDL_PollEvent(&event) && event.type == SDL_QUIT)
    			break;
    	}
	//Wait for user to press key
	scanf("%f", &zoom);

    	if (renderer) SDL_DestroyRenderer(renderer);
    	if (window) SDL_DestroyWindow(window);
    	SDL_Quit();

    	return EXIT_SUCCESS;
}

/* CHAT-GPT FUNCTIONS */
// Function to trim whitespace from a string (helper function)
char *trimWhitespace(char *str) {
    char *end;

    // Trim leading space
    while(isspace((unsigned char)*str)) str++;

    if(*str == 0)  // All spaces?
        return str;

    // Trim trailing space
    end = str + strlen(str) - 1;
    while(end > str && isspace((unsigned char)*end)) end--;

    // Write new null terminator
    *(end+1) = 0;

    return str;
}

// Function to load the settings from the file
void loadSettings(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        printf("Error opening file '%s'\n", filename);
        exit(1);
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        if (line[0] == '#' || line[0] == '\n') continue;

        char *key = trimWhitespace(strtok(line, "="));
        char *value = trimWhitespace(strtok(NULL, "="));

        if (!key || !value) continue;

        if (strcmp(key, "viewSequence") == 0) {
            viewSequence = atoi(value);
        } else if (strcmp(key, "zoom") == 0) {
            zoom = atoi(value);
        } else if (strcmp(key, "zoomInPercent") == 0) {
            zoomInPercent = atoi(value);
        } else if (strcmp(key, "depth") == 0) {
            depth = atoi(value);
        } else if (strcmp(key, "max") == 0) {
            max = atoi(value);
        } else if (strcmp(key, "width") == 0) {
            width = atoi(value);
        } else if (strcmp(key, "height") == 0) {
            height = atoi(value);
        } else if (strcmp(key, "offset_Re") == 0) {
            offset_Re = strtold(value, NULL);
        } else if (strcmp(key, "offset_Im") == 0) {
            offset_Im = strtold(value, NULL);
        } else if (strcmp(key, "threads") == 0) {
            threads = atoi(value);
        }
    }

    fclose(file);
}
