within TransiEnt.Consumer.Systems.Systems_DistrictHeating.Check;
model centralSupply_GasBoiler

//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.2                             //
//                                                                                //
// Licensed by Hamburg University of Technology under the 3-BSD-clause.           //
// Copyright 2021, Hamburg University of Technology.                              //
//________________________________________________________________________________//
//                                                                                //
// TransiEnt.EE, ResiliEntEE, IntegraNet and IntegraNet II are research projects  //
// supported by the German Federal Ministry of Economics and Energy               //
// (FKZ 03ET4003, 03ET4048, 0324027 and 03EI1008).                                //
// The TransiEnt Library research team consists of the following project partners://
// Institute of Engineering Thermodynamics (Hamburg University of Technology),    //
// Institute of Energy Systems (Hamburg University of Technology),                //
// Institute of Electrical Power and Energy Technology                            //
// (Hamburg University of Technology)                                             //
// Fraunhofer Institute for Environmental, Safety, and Energy Technology UMSICHT, //
// Gas- und Wärme-Institut Essen                                                  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//

  extends TransiEnt.Basics.Icons.Checkmodel;

  inner TransiEnt.SimCenter simCenter(redeclare TransiEnt.Components.Boundaries.Ambient.AmbientConditions_Hamburg_TMY ambientConditions,
    T_supply=393.15,
    K(displayUnit="mm") = 2e-05)                                                                                                         annotation (Placement(transformation(extent={{-86,78},{-66,98}})));
  inner TransiEnt.ModelStatistics modelStatistics annotation (Placement(transformation(extent={{-48,78},{-28,98}})));
  TransiEnt.Components.Boundaries.Electrical.ApparentPower.FrequencyVoltage ElectricGrid(
    Use_input_connector_f=false,
    Use_input_connector_v=false,
    v_boundary=400) annotation (Placement(transformation(extent={{-62,6},{-78,-12}})));
  TransiEnt.SystemGeneration.GridConstructor.GridConstructor grid(
    gas_in=false,
    gas_out=false,
    el_out=false,
    dhn_in_s=true,
    dhn_out_s=false,
    dhn_in_r=false,
    dhn_out_r=true,
    redeclare model Demand_Consumer_1 = TransiEnt.Basics.Tables.Combined.CombinedTables.Demand_3Tables (relativepath_heating="heat/Household/Heating_20Households_simulated_6MWh_3600s.csv", relativepath_dhw="heat/Household/HotWater_20Households_VEDIS_1.5MWh_60s.txt"),
    redeclare model Demand_Consumer_2 = TransiEnt.Basics.Tables.Combined.CombinedTables.Demand_3Tables (relativepath_dhw="heat/Household/HotWater_20Households_VEDIS_1.5MWh_60s.txt"),
    start_c2=3,
    n_elements=2,
    second_row=true,
    Technologies_1={TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(Boiler=0, DHN=1),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(heatPump=0, DHN=1),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix()},
    Technologies_2={TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(Boiler=0, DHN=1),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(heatPump=0, DHN=1),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.TechnologyMatrix()},
    HeatPumpParameters_1={TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(
        Q_flow_n=4000,
        COP_n=3.5,
        T_source="T_ambient"),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.HeatPumpParameters()},
    second_Consumer={true,false},
    DHNParameters_Main={TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(length=50),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(length=50),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),
        TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),
           TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters(),TransiEnt.SystemGeneration.GridConstructor.DataRecords.DHNParameters()})
                                  annotation (Placement(transformation(extent={{44,8},{74,32}})));
  ClaRa.Components.BoundaryConditions.BoundaryVLE_pTxi supply_boundary(p_const=10e5, T_const(displayUnit="degC") = 363.15) annotation (Placement(transformation(extent={{-80,46},{-64,62}})));
  ClaRa.Components.BoundaryConditions.BoundaryVLE_pTxi return_boundary(p_const=5e5, T_const(displayUnit="degC") = 343.15)                 annotation (Placement(transformation(extent={{-80,26},{-64,40}})));
  ClaRa.Components.Sensors.SensorVLE_L1_T T_supply annotation (Placement(transformation(extent={{18,50},{38,70}})));
  ClaRa.Components.Sensors.SensorVLE_L1_T T_return annotation (Placement(transformation(extent={{18,-14},{38,-34}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_demand_heating_grid(y=grid.Basic_Grid_Elements[1].main_dhn_pipe.waterPortIn_supply.m_flow*4200*(T_supply.T - T_return.T)) annotation (Placement(transformation(
        extent={{-11.5,-10},{11.5,10}},
        rotation=0,
        origin={-64.5,-56})));
  Boiler_DistrictHeating boiler_DistrictHeating(useGasPort=false, useElectricityPort=false) annotation (Placement(transformation(extent={{-42,-84},{-22,-64}})));
equation
  connect(ElectricGrid.epp, grid.epp_p) annotation (Line(
      points={{-62,-3},{38,-3},{38,14},{44,14}},
      color={0,127,0},
      thickness=0.5));
  connect(return_boundary.steam_a, grid.waterPortOut_return) annotation (Line(
      points={{-64,33},{-20,33},{-20,18},{44,18}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(supply_boundary.steam_a, grid.waterPortIn_supply) annotation (Line(
      points={{-64,54},{-16,54},{-16,22},{44,22}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(T_supply.port, grid.waterPortIn_supply) annotation (Line(
      points={{28,50},{28,22},{44,22}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(T_return.port, grid.waterPortOut_return) annotation (Line(
      points={{28,-14},{28,18},{44,18}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(Q_flow_demand_heating_grid.y, boiler_DistrictHeating.heatDemand) annotation (Line(points={{-51.85,-56},{-32,-56},{-32,-63.6}}, color={0,0,127}));
  annotation (                                  experiment(
      StopTime=604800,
      Interval=3600.00288,
      __Dymola_Algorithm="Cvode"),
    __Dymola_experimentSetupOutput(events=false));
end centralSupply_GasBoiler;
