Note for how to retrain or fine-tune the codes in lower speed 


# Debug the project

## Recompile Quadrotor model (Necessary for applying MPC in real application)
Install the package
```sh
cd ~ && git clone https://github.com/acado/acado.git -b stable ACADOtoolkit && cd ~/ACADOtoolkit && mkdir build && cd build && cmake .. && make && cd .. && cd examples/getting_started && ./simple_ocp
```
It means successful by seeing a plotted window. **Every time when we want to recompile quadrotor model**, we need to start by:
```
source /home/qiyuan/ACADOtoolkit/build/acado_env.sh
```
Delete `quadrotor_model_codegen` and `quadrotor_mpc_codegen` in `rpg_mpc/model/`. Then, we can modify our model in `quadrotor_model_thrustrates.cpp` and rebuild:
```sh
# generate quadrotor_model_codegen
cd ~/agile_autonomy_ws/src/rpg_mpc/model/ && cmake . && make

# generate quadrotor_mpc_codegen
./quadrotor_model_codegen
```
Next, we also need to modify `parameters` in `rpg_quadrotor_control/simulation/rpg_rotors_interface`.