{
  "datadir": "data/bingham-mrt_5000_500_20_006_004000",
  "dx": 1.0,
  "dt": 1.0,
  "ni": 500,
  "nj": 20,
  "rhoo": 1.0,
  "nu": 0.06,
  "mu_p": 0.06,
  "tau_y": 4.0e-3,
  "m": 100000,
  "max_iters": 20,
  "tol": 0.005,
  "nsteps": 5000,
  "stepout": 500,
  "col_f": "begin;
              curry_mrt_bingham_col_f!(lat, msm) = mrt_bingham_col_f!(lat, msm,
                vikhansky_relax_matrix, 0.06, 4.0e-3, 1.0e6, 20, 5.0e-3, 1.0e-11
                );
              return curry_mrt_bingham_col_f!;
            end",
  "bcs": [
    "north_bounce_back!",
    "south_bounce_back!",
    "periodic_east_to_west!"
  ]
}
