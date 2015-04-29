{
  "rhoo": 5.0,
  "dx": 1.0,
  "dt": 1.0,
  "ni": 1000,
  "nj": 100,
  "nu": 0.02,
  "nsteps": 10000,
  "stepout": 500,
  "col_f": "srt_col_f!",
  "bcs": [
      "north_bounce_back!",
      "south_bounce_back!",
      "begin;
        curry_west_bc!(lat) = west_inlet!(lat, 0.04);
        curry_west_bc!;
      end",
      "east_open!"
  ],
  "u_inlet": 0.04
}