# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var du4_lgt = props.globals.getNode("/controls/lighting/DU/du4", 1);
var apu_load = props.globals.initNode("/systems/electrical/extra/apu-load", 0, "DOUBLE");
var gen1_load = props.globals.initNode("/systems/electrical/extra/gen1-load", 0, "DOUBLE");
var gen2_load = props.globals.initNode("/systems/electrical/extra/gen2-load", 0, "DOUBLE");
var du4_test = props.globals.initNode("/instrumentation/du/du4-test", 0, "BOOL");
var du4_test_time = props.globals.initNode("/instrumentation/du/du4-test-time", 0, "DOUBLE");
var du4_test_amount = props.globals.initNode("/instrumentation/du/du4-test-amount", 0, "DOUBLE");
var du4_offtime = props.globals.initNode("/instrumentation/du/du4-off-time", 0.0, "DOUBLE");

var canvas_lowerECAMPage =
{
	new: func(svg) {
		var obj = {parents: [canvas_lowerECAMPage] };
		obj.canvas = canvas.new({
			"name": "lowerECAM",
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1
		});
		
		obj.canvas.addPlacement({"node": "lecam.screen"});
        obj.group = obj.canvas.createGroup();
        obj.test = obj.canvas.createGroup();
		
		obj.font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(obj.group, svg, {"font-mapper": obj.font_mapper} );
		obj.keysHash = obj.getKeys();
		
 		foreach(var key; obj.keysHash) {
			obj[key] = obj.group.getElementById(key);
		};
		
		canvas.parsesvg(obj.test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg", {"font-mapper": obj.font_mapper} );
		foreach(var key; obj.getKeysTest()) {
			obj[key] = obj.test.getElementById(key);
		};
		
		obj.units = acconfig_weight_kgs.getValue();
		
		# init
		obj["APUGenOff"].hide();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("apuFlap",1, func(val) {
				if (val) {
					obj["APUFlapOpen"].show();
				} else {
					obj["APUFlapOpen"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuNeedleRot",0.1, func(val) {
				obj["APUN-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("apuEgtRot",0.1, func(val) {
				obj["APUEGT-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("apuAvailable", nil, func(val) {
				if (val) {
					obj["APUAvail"].show();
				} else {
					obj["APUAvail"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuRpm","apuEgt","apuMaster","apuGenPB"], nil, func(val) {
				if (val.apuRpm > 0.001) {
					obj["APUN"].setColor(0.0509,0.7529,0.2941);
					obj["APUN"].setText(sprintf("%s", math.round(val.apuRpm)));
					obj["APUN-needle"].show();
					obj["APUEGT"].setColor(0.0509,0.7529,0.2941);
					obj["APUEGT"].setText(sprintf("%s", math.round(val.apuEgt, 5)));
					obj["APUEGT-needle"].show();
				} else {
					obj["APUN"].setColor(0.7333,0.3803,0);
					obj["APUN"].setText(sprintf("%s", "XX"));
					obj["APUN-needle"].hide();
					obj["APUEGT"].setColor(0.7333,0.3803,0);
					obj["APUEGT"].setText(sprintf("%s", "XX"));
					obj["APUEGT-needle"].hide();
				}
				
				if (val.apuMaster or val.apuRpm >= 94.9) {
					obj["APUGenbox"].show();
					if (val.apuGenPB) {
						obj["APUGenOff"].hide();
						obj["APUGentext"].setColor(0.8078,0.8039,0.8078);
						obj["APUGenHz"].show();
						obj["APUGenVolt"].show();
						obj["APUGenLoad"].show();
						obj["text3724"].show();
						obj["text3728"].show();
						obj["text3732"].show();
					} else {
						obj["APUGenOff"].show();
						obj["APUGentext"].setColor(0.7333,0.3803,0);
						obj["APUGenHz"].hide();
						obj["APUGenVolt"].hide();
						obj["APUGenLoad"].hide();
						obj["text3724"].hide();
						obj["text3728"].hide();
						obj["text3732"].hide();
					}
				} else {
					obj["APUGentext"].setColor(0.8078,0.8039,0.8078);
					obj["APUGenbox"].hide();
					obj["APUGenHz"].hide();
					obj["APUGenVolt"].hide();
					obj["APUGenLoad"].hide();
					obj["text3724"].hide();
					obj["text3728"].hide();
					obj["text3732"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuFuelPumpsOff","apuFuelPump"], nil, func(val) {
				if (val.apuFuelPumpsOff and !val.apuFuelPump) {
					obj["APUfuelLO"].show();
				} else {
					obj["APUfuelLO"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuRpm","apuOilLevel","gear0Wow"], nil, func(val) {
				if (val.apuRpm >= 94.9 and val.gear0Wow and val.apuOilLevel < 3.69) {
					obj["APU-low-oil"].show();
				} else {
					obj["APU-low-oil"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuAdr","apuPsi","apuRpm"], nil, func(val) {
				if (val.apuAdr and val.apuRpm > 0.001) {
					obj["APUBleedPSI"].setColor(0.0509,0.7529,0.2941);
					obj["APUBleedPSI"].setText(sprintf("%s", math.round(val.apuPsi)));
				} else {
					obj["APUBleedPSI"].setColor(0.7333,0.3803,0);
					obj["APUBleedPSI"].setText(sprintf("%s", "XX"));
				}
			}),
			props.UpdateManager.FromHashValue("apuLoad", 0.1, func(val) {
				obj["APUGenLoad"].setText(sprintf("%s", math.round(val)));
				
				if (val <= 100) {
					obj["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenHz"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuHertz", 1, func(val) {
				obj["APUGenHz"].setText(sprintf("%s", math.round(val)));
				
				if (val >= 390 and val <= 410) {
					obj["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenHz"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuVolt", 0.1, func(val) {
				obj["APUGenVolt"].setText(sprintf("%s", math.round(val)));
				
				if (val >= 110 and val <= 120) {
					obj["APUGenVolt"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenVolt"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuGLC", nil, func(val) {
				if (val) {
					obj["APUGenOnline"].show();
				} else {
					obj["APUGenOnline"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuBleedValvePos","apuBleedValveCmd"], nil, func(val) {
				if (val.apuBleedValvePos == 1) {
					obj["APUBleedValve"].setRotation(90 * D2R);
					obj["APUBleedOnline"].show();
				} else {
					obj["APUBleedValve"].setRotation(0);
					obj["APUBleedOnline"].hide();
				}
				
				if (val.apuBleedValveCmd == val.apuBleedValvePos) {
					obj["APUBleedValveCrossBar"].setColor(0.0509,0.7529,0.2941);
					obj["APUBleedValveCrossBar"].setColorFill(0.0509,0.7529,0.2941);
					obj["APUBleedValve"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUBleedValveCrossBar"].setColor(0.7333,0.3803,0);
					obj["APUBleedValveCrossBar"].setColorFill(0.7333,0.3803,0);
					obj["APUBleedValve"].setColor(0.7333,0.3803,0);
				}
			}),
		];
		return obj;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GLoad","GW-weight-unit","APUN-needle","APUEGT-needle","APUN","APUEGT","APUAvail","APUFlapOpen","APUBleedValve","APUBleedOnline","APUBleedValveCrossBar","APUGenOnline","APUGenOff","APUGentext","APUGenLoad","APUGenbox","APUGenVolt","APUGenHz","APUBleedPSI","APUfuelLO","APU-low-oil",
		"text3724","text3728","text3732"];
	},
	getKeysTest: func() {
		return ["Test_white","Test_text"];
	},
	update: func(notification) {
		me.updatePower();
		
		if (me.test.getVisible() == 1) {
			me.updateTest(notification);
		}
		
		if (me.group.getVisible() == 0) {
			return;
		}
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
	},
	updateTest: func(notification) {
		if (du4_test_time.getValue() + 1 >= notification.elapsedTime) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
	powerTransient: func() {
		if (systems.ELEC.Bus.ac2.getValue() >= 110) {
			if (du4_offtime.getValue() + 3 < pts.Sim.Time.elapsedSec.getValue()) {
				if (pts.Gear.wow[0].getValue()) {
					if (!acconfig.getBoolValue() and !du4_test.getBoolValue()) {
						du4_test.setValue(1);
						du4_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du4_test_time.setValue(pts.Sim.Time.elapsedSec.getValue());
					} else if (acconfig.getBoolValue() and !du4_test.getBoolValue()) {
						du4_test.setValue(1);
						du4_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du4_test_time.setValue(pts.Sim.Time.elapsedSec.getValue() - 30);
					}
				} else {
					du4_test.setValue(1);
					du4_test_amount.setValue(0);
					du4_test_time.setValue(-100);
				}
			}
		} else {
			du4_test.setValue(0);
			du4_offtime.setValue(pts.Sim.Time.elapsedSec.getValue());
		}
	},
	updatePower: func() {
		if (du4_lgt.getValue() > 0.01 and systems.ELEC.Bus.ac2.getValue() >= 110) {
			if (du4_test_time.getValue() + du4_test_amount.getValue() >= pts.Sim.Time.elapsedSec.getValue()) {
				me.group.setVisible(0);
				me.test.setVisible(1);
			} else {
				me.group.setVisible(1);
				me.test.setVisible(0);
			}
		} else {
			me.group.setVisible(0);
			me.test.setVisible(0);
		}
	},
};

var SystemDisplayPageRecipient =
{
	new: func(_ident, page)
	{
		var SDRecipient = emesary.Recipient.new(_ident);
		SDRecipient.MainScreen = nil;
		SDRecipient.Page = page;
		SDRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (SDRecipient.MainScreen == nil) {
					SDRecipient.MainScreen = canvas_lowerECAMPage.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/" ~ SDRecipient.Page ~ ".svg");
				}
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					#if (ecam.SystemDisplayController.displayedPage.name == SDRecipient.Page) {
						SDRecipient.MainScreen.update(notification);
					#}
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return SDRecipient;
	},
};

var A320SDAPU = SystemDisplayPageRecipient.new("A320 SD", "apu");
emesary.GlobalTransmitter.Register(A320SDAPU);


var input = {
	apuAdr: "/systems/navigation/adr/operating-1",
	apuAvailable: "/systems/apu/available",
	apuBleed: "/controls/pneumatics/switches/apu",
	apuBleedValveCmd: "/systems/pneumatics/valves/apu-bleed-valve-cmd",
	apuBleedValvePos: "/systems/pneumatics/valves/apu-bleed-valve",
	apuEgt: "/systems/apu/egt-degC",
	apuEgtRot: "/ECAM/Lower/APU-EGT",
	apuGenPB: "/controls/electrical/switches/apu",
	apuGLC: "/systems/electrical/relay/apu-glc/contact-pos",
	apuFlap: "/controls/apu/inlet-flap/position-norm",
	apuFuelPump: "/systems/fuel/pumps/apu-operate",
	apuFuelPumpsOff: "/systems/fuel/pumps/all-eng-pump-off",
	apuOilLevel: "/systems/apu/oil/level-l",
	apuMaster: "/controls/apu/master",
	apuNeedleRot: "/ECAM/Lower/APU-N",
	apuRpm: "/engines/engine[2]/n1",
	apuPsi: "/systems/pneumatics/source/apu-psi",
	apuLoad: "/systems/electrical/extra/apu-load",
	apuHertz: "/systems/electrical/sources/apu/output-hertz",
	apuVolt: "/systems/electrical/sources/apu/output-volt",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 Lower ECAM", name, input[name]));
}

setlistener("/systems/electrical/bus/ac-2", func() {
	if (A320SDAPU.MainScreen != nil) { A320SDAPU.MainScreen.powerTransient() }
}, 0, 0);