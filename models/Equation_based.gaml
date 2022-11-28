
model Equationbased

global {
	float step <- 1 # s;
	init {
		create my_equation;
	}
}
species my_equation { 	
	
	float E <- 0.3;
	float K <- 100.0;
	float r <- 0.5;
	float h <- 0.01;
	float E1 <- 5.0 * h;
	
	float N <- 10.0;
	float t;
	float Y;
	
	equation EQ {			
		diff(N, t) = r * N * (1 - N/K) - E * N;
	}

	reflex solving {
		solve EQ method: #rk4 step_size: 0.01;
		
//		Y <- E * K  * (1 - E / r);
		Y <- E * N;
		N <- N - E1;
	}
}

experiment mysimulation type: gui {
	output {
		display chartcontinuous {
			chart 'chart for population' type: series background: rgb('white') 
				x_serie: (my_equation[0]).t[]
				size: { 1.0, 0.5 } position: { 0.0, 0.0 }
			{
				data "Nt" value: (my_equation[0]).N[] color: # red marker: false;
			}

			chart 'chart for yeild' type: series background: rgb('white') size: { 1.0, 0.5 } position: { 0.0, 0.5 } {
				data "Yt" value: first(my_equation).Y color: rgb('red') marker: false;
			
			}
	
		}
	}
}



