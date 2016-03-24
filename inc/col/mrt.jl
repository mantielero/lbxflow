# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#! Multiple relaxation time collision operator 
type MRT <: ColFunction
  feq_f::LBXFunction;
  constit_relation_f::LBXFunction;
  M::Matrix{Float64};
  iM::Matrix{Float64};
  S::LBXFunction;

  function MRT(constit_relation_f::LBXFunction; feq_f::LBXFunction=feq_incomp,
               S::LBXFunction=S_fallah)
    return new(feq_f, constit_relation_f, @DEFAULT_MRT_M(), @DEFAULT_MRT_IM(), 
               S);
  end
end

#! Multiple relaxation time collision operator with forcing 
type MRT_F <: ColFunction
  feq_f::LBXFunction;
  constit_relation_f::LBXFunction;
  forcing_f::Force;
  M::Matrix{Float64};
  iM::Matrix{Float64};
  S::LBXFunction;

  function MRT(constit_relation_f::LBXFunction
               forcing_f::Force; 
               feq_f::LBXFunction=feq_incomp, S::LBXFunction=S_fallah)
    return new(feq_f, constit_relation_f, forcing_f, 
               @DEFAULT_MRT_M(), @DEFAULT_MRT_IM(), S);
  end
end

#! Perform collision over box regions of the domain
#!
#! \param   sim     Simulation
#! \param   bounds  Each column of the matrix defines a box region
function call(col_f::MRT, sim::AbstractSim, bounds::Matrix{Int64})
  lat           =   sim.lat;
  msm           =   sim.msm;
  const ni, nj  =   size(msm.rho);
  const nbounds =   size(bounds, 2);

  for r = 1:nbounds
    i_min, i_max, j_min, j_max = bounds[:,r];
    for j = j_min:j_max, i = i_min:i_max

      rhoij       =   msm.rho[i,j];
      uij         =   msm.u[:,i,j];
      feq         =   Vector{Float64}(lat.n);
      fneq        =   Vector{Float64}(lat.n);

      for k = 1:lat.n 
        feq[k]          =   col_f.feq_f(lat, rhoij, uij, k);
        fneq[k]         =   lat.f[k,i,j] - feq[k];
      end

      const mu        =   col_f.constit_relation_f(sim, fneq, i, j);
      const Sij       =   col_f.S(mu, rhoij, lat.cssq, lat.dt);

      lat.f[:,i,j]  -= col_f.iM * Sij * col_f.M * fneq;

      # update collision frequency matrix
      msm.omega[i,j] = @omega(mu, lat.cssq, lat.dt);

    end
  end
end

#! Perform collision over box regions of the domain
#!
#! \param   sim     Simulation
#! \param   bounds  Each column of the matrix defines a box region
function call(col_f::MRT_F, sim::AbstractSim, bounds::Matrix{Int64})
  lat           =   sim.lat;
  msm           =   sim.msm;
  const ni, nj  =   size(msm.rho);
  const nbounds =   size(bounds, 2);

  for r = 1:nbounds
    i_min, i_max, j_min, j_max = bounds[:,r];
    for j = j_min:j_max, i = i_min:i_max

      rhoij       =   msm.rho[i,j];
      uij         =   col_f.forcing_f[1](sim, i, j);
      feq         =   Vector{Float64}(lat.n);
      fneq        =   Vector{Float64}(lat.n);

      for k = 1:lat.n 
        feq[k]          =   col_f.feq_f(lat, rhoij, uij, k);
        fneq[k]         =   lat.f[k,i,j] - feq[k];
      end

      const mu    =   col_f.constit_relation_f(sim, fneq, i, j);
      const Sij   =   col_f.S(mu, rhoij, lat.cssq, lat.dt);
      const F     =   map(k -> col_f.forcing_f[2](sim, mu, k, i, j), 1:lat.n);

      lat.f[:,i,j]  -= col_f.iM * Sij * col_f.M * fneq + F;

      # update collision frequency matrix
      msm.omega[i,j] = @omega(mu, lat.cssq, lat.dt);

    end
  end
end

#! Perform collision over box regions of the domain
#!
#! \param   sim     Simulation
#! \param   bounds  Each column of the matrix defines a box region
function call(col_f::MRT, sim::FreeSurfSim, bounds::Matrix{Int64})
  lat           =   sim.lat;
  msm           =   sim.msm;
  const ni, nj  =   size(msm.rho);
  const nbounds =   size(bounds, 2);

  for r = 1:nbounds
    i_min, i_max, j_min, j_max = bounds[:,r];
    for j = j_min:j_max, i = i_min:i_max

      if sim.t.state[i, j] != GAS

        rhoij       =   msm.rho[i,j];
        uij         =   msm.u[:,i,j];
        feq         =   Vector{Float64}(lat.n);
        fneq        =   Vector{Float64}(lat.n);

        for k = 1:lat.n 
          feq[k]          =   col_f.feq_f(lat, rhoij, uij, k);
          fneq[k]         =   lat.f[k,i,j] - feq[k];
        end

        const mu        =   col_f.constit_relation_f(sim, fneq, i, j);
        const Sij       =   col_f.S(mu, rhoij, lat.cssq, lat.dt);

        lat.f[:,i,j]  -= col_f.iM * Sij * col_f.M * fneq;

        # update collision frequency matrix
        msm.omega[i,j] = @omega(mu, lat.cssq, lat.dt);

      end

    end
  end
end

#! Perform collision over box regions of the domain
#!
#! \param   sim     Simulation
#! \param   bounds  Each column of the matrix defines a box region
function call(col_f::MRT_F, sim::FreeSurfSim, bounds::Matrix{Int64})
  lat           =   sim.lat;
  msm           =   sim.msm;
  const ni, nj  =   size(msm.rho);
  const nbounds =   size(bounds, 2);

  for r = 1:nbounds
    i_min, i_max, j_min, j_max = bounds[:,r];
    for j = j_min:j_max, i = i_min:i_max

      if sim.t.state[i, j] != GAS

        rhoij       =   msm.rho[i,j];
        uij         =   col_f.forcing_f[1](sim, i, j);
        feq         =   Vector{Float64}(lat.n);
        fneq        =   Vector{Float64}(lat.n);

        for k = 1:lat.n 
          feq[k]          =   col_f.feq_f(lat, rhoij, uij, k);
          fneq[k]         =   lat.f[k,i,j] - feq[k];
        end

        const mu    =   col_f.constit_relation_f(sim, fneq, i, j);
        const Sij   =   col_f.S(mu, rhoij, lat.cssq, lat.dt);
        const F     =   map(k -> col_f.forcing_f[2](sim, mu, k, i, j), 1:lat.n);

        lat.f[:,i,j]  -= col_f.iM * Sij * col_f.M * fneq + F;

        # update collision frequency matrix
        msm.omega[i,j] = @omega(mu, lat.cssq, lat.dt);

      end

    end
  end
end
