﻿within TransiEnt.Consumer;
package Systems



//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.3                             //
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
// Gas- und WÃ¤rme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//




  extends TransiEnt.Basics.Icons.Package;














annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
      Ellipse(extent={{-70,58},{-42,30}}, lineColor={0,0,0}),
      Ellipse(extent={{28,74},{56,46}}, lineColor={0,0,0}),
      Ellipse(extent={{-42,-2},{-14,-30}}, lineColor={0,0,0}),
      Ellipse(extent={{28,-18},{56,-46}}, lineColor={0,0,0}),
      Line(
        points={{-42,48},{28,56}},
        color={0,0,0},
        smooth=Smooth.None),
      Line(
        points={{46,46},{48,-20}},
        color={0,0,0},
        smooth=Smooth.None),
      Line(
        points={{-48,32},{-34,-4}},
        color={0,0,0},
        smooth=Smooth.None),
      Line(
        points={{-14,-22},{28,-36}},
        color={0,0,0},
        smooth=Smooth.None)}));
end Systems;
