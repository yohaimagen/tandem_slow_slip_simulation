mpiexec -n $2 --bind-to core --map-by core /home/tandem/build_2d_6p/app/tandem $1 --petsc -options_file solver.cfg | tee ts.log