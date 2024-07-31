// Configs
S.cfga({
  defaultToCurrentScreen: true,
  secondsBetweenRepeat: 0.1,
  checkDefaultsOnLoad: true,
  focusCheckWidthMax: 3000,
  orderScreensLeftToRight: true,
});

// Monitors
var monTbolt = "3840x2160";
var monLaptop = "3072x1920";
var monVertical = "1080x1920";
// Set up screen reference variables to avoid typos :)
var leftScreenRef = "0";
var middleScreenRef = "1";
var rightScreenRef = "2";
// Operations
var lapFull = S.op("move", {
  screen: monLaptop,
  x: "screenOriginX",
  y: "screenOriginY",
  width: "screenSizeX",
  height: "screenSizeY",
});
var lapChat = S.op("corner", {
  screen: monLaptop,
  direction: "top-left",
  width: "screenSizeX/9",
  height: "screenSizeY",
});
var lapMain = lapChat.dup({ direction: "top-right", width: "8*screenSizeX/9" });
var tboltFull = S.op("move", {
  screen: monTbolt,
  x: "screenOriginX",
  y: "screenOriginY",
  width: "screenSizeX",
  height: "screenSizeY",
});
var tboltBig = S.op("move", {
  screen: monTbolt,
  x: "screenOriginX+screenSizeX/3",
  y: "screenOriginY",
  width: "screenSizeX*2/3",
  height: "screenSizeY",
});
var tboltLeft = tboltFull.dup({ width: "screenSizeX/3" });
var tboltLeftHalf = tboltFull.dup({ width: "screenSizeX/2" });
var tboltMid = tboltLeft.dup({ x: "screenOriginX+screenSizeX/3" });
var tboltRight = tboltLeft.dup({ x: "screenOriginX+(screenSizeX*2/3)" });
var tboltLeftTop = tboltLeft.dup({ height: "screenSizeY/2" });
var tboltLeftBot = tboltLeftTop.dup({ y: "screenOriginY+screenSizeY/2" });
var tboltMidTop = tboltMid.dup({ height: "screenSizeY/2" });
var tboltMidBot = tboltMidTop.dup({ y: "screenOriginY+screenSizeY/2" });
var tboltRightTop = tboltRight.dup({ height: "screenSizeY/2" });
var tboltRightBot = tboltRightTop.dup({ y: "screenOriginY+screenSizeY/2" });
var tboltRightHalf = tboltRight.dup({
  x: "screenOriginX+(screenSizeX*1/2)",
  width: "screenSizeX/2",
});

var hideSpotify = slate.operation("hide", { app: "Spotify" });
var hideMessages = slate.operation("hide", { app: "Messages" });
var focusITerm = slate.operation("focus", { app: "iTerm" });
var focusEditor = slate.operation("focus", { app: "Code" });

// common layout hashes
var lapMainHash = {
  operations: [lapMain],
  "ignore-fail": true,
  repeat: true,
};
var lapFullHash = {
  operations: [lapFull],
  "ignore-fail": true,
  repeat: true,
};
var adiumHash = {
  operations: [lapChat, lapMain],
  "ignore-fail": true,
  "title-order": ["Contacts"],
  "repeat-last": true,
};
var mvimHash = {
  operations: [tboltMid, tboltRightTop],
  repeat: true,
};
var tboltBigHash = {
  operations: [tboltBig],
  "sort-title": true,
  repeat: true,
};
var tboltFullHash = {
  operations: [tboltFull],
  "sort-title": true,
  repeat: true,
};
var genBrowserHash = function (regex) {
  return {
    operations: [
      function (windowObject) {
        var title = windowObject.title();
        if (title !== undefined && title.match(regex)) {
          windowObject.doOperation(tboltLeftBot);
        } else {
          windowObject.doOperation(lapFull);
        }
      },
    ],
    "ignore-fail": true,
    repeat: true,
  };
};

var middleLeftHalf = slate.operation("push", {
  screen: middleScreenRef,
  direction: "left",
  style: "bar-resize:screenSizeX/2",
});

var middleRightHalf = slate.operation("push", {
  screen: middleScreenRef,
  direction: "right",
  style: "bar-resize:screenSizeX/2",
});

var rightTopHalf = slate.operation("push", {
  screen: rightScreenRef,
  direction: "top",
  style: "bar-resize:screenSizeY/2",
});
var rightBottomHalf = slate.operation("push", {
  screen: rightScreenRef,
  direction: "bottom",
  style: "bar-resize:screenSizeY/2",
});

var leftFullScreen = slate.operation("move", {
  screen: leftScreenRef,
  x: "screenOriginX",
  y: "screenOriginY",
  width: "screenSizeX",
  height: "screenSizeY",
});

var leftScreenPortion = function (sizeX = "screenSizeX/2") {
  return slate.operation("move", {
    x: "screenOriginX",
    y: "screenOriginY",
    width: sizeX,
    height: "screenSizeY",
  });
};
var rightScreenPortion = function (sizeX = "screenSizeX/2") {
  return slate.operation("move", {
    direction: "right",
    x: "screenOriginX+screenSizeX-" + sizeX, // offset top left of window by sizeX
    y: "screenOriginY",
    width: sizeX,
    height: "screenSizeY",
  });
};

// Dev Zen Layout
var devZenLayout = S.layout("devZen", {
  _before_: { operations: [hideMessages, hideSpotify] },
  _after_: { operations: [focusEditor] },
  Slack: lapFullHash,
  "Google Chrome": {
    operations: [
      function (windowObject) {
        // I want all Google Chrome windows to use the rightMain operation *unless* it is a Developer Tools window.
        // In that case I want it to use the leftRight operation. I can't use title-order-regex here because if it
        // doesn't see the regex, it won't skip the leftRight operation and that will cause one of my other Chrome
        // windows to use it which I don't want. Also, I could have multiple Developer Tools windows which also
        // makes title-order-regex unusable. So instead I just write my own free form operation.
        var title = windowObject.title();
        if (title !== undefined && title.match(/^DevTools\s-\s.+$/)) {
          windowObject.doOperation(lapFull);
        } else {
          windowObject.doOperation(leftScreenPortion("screenSizeX*2/5"));
        }
      },
    ],
    "ignore-fail": true, // Chrome has issues sometimes so I add ignore-fail so that Slate doesn't stop the
    // layout if Chrome is being stupid.
    repeat: true, // Keep repeating the function above for all windows in Chrome.
  },
  Code: {
    operations: rightScreenPortion("screenSizeX*3/5"),
    repeat: true,
  },
});
// 3 monitor layout
var threeMonitorLayout = S.lay("threeMonitor", {
  _before_: { operations: hideSpotify }, // before the layout is activated, hide Spotify
  _after_: { operations: focusITerm }, // after the layout is activated, focus iTerm
  Slack: {
    operations: rightBottomHalf,
  },
  "Google Chrome": {
    operations: [
      function (windowObject) {
        // I want all Google Chrome windows to use the rightMain operation *unless* it is a Developer Tools window.
        // In that case I want it to use the leftRight operation. I can't use title-order-regex here because if it
        // doesn't see the regex, it won't skip the leftRight operation and that will cause one of my other Chrome
        // windows to use it which I don't want. Also, I could have multiple Developer Tools windows which also
        // makes title-order-regex unusable. So instead I just write my own free form operation.
        var title = windowObject.title();
        if (title !== undefined && title.match(/^DevTools\s-\s.+$/)) {
          windowObject.doOperation(rightTopHalf);
        } else {
          windowObject.doOperation(middleLeftHalf);
        }
      },
    ],
    "ignore-fail": true, // Chrome has issues sometimes so I add ignore-fail so that Slate doesn't stop the
    // layout if Chrome is being stupid.
    repeat: true, // Keep repeating the function above for all windows in Chrome.
  },
  Code: {
    operations: middleRightHalf,
  },
  iTerm: {
    operations: leftFullScreen,
  },
});
// 2 monitor layout
// var twoMonitorLayout = S.lay('twoMonitor', {
//   Adium: {
//     operations: [lapChat, lapMain],
//     'ignore-fail': true,
//     'title-order': ['Contacts'],
//     'repeat-last': true,
//   },
//   MacVim: mvimHash,
//   iTerm: tboltFullHash,
//   Xcode: tboltBigHash,
//   'Google Chrome': genBrowserHash(/^Developer\sTools\s-\s.+$/),
//   GitX: {
//     operations: [lapFull],
//     repeat: true,
//   },
//   Firefox: genBrowserHash(/^Firebug\s-\s.+$/),
//   Safari: lapFullHash,
//   Spotify: {
//     operations: [lapFull],
//     repeat: true,
//   },
//   TextEdit: {
//     operations: [lapFull],
//     repeat: true,
//   },
// });

// 1 monitor layout
var oneMonitorLayout = S.lay("oneMonitor", {
  Adium: adiumHash,
  MacVim: lapFullHash,
  iTerm: lapFullHash,
  "Google Chrome": lapFullHash,
  Xcode: lapFullHash,
  GitX: lapFullHash,
  Firefox: lapFullHash,
  Safari: lapFullHash,
  Spotify: lapFullHash,
});

// Defaults
S.def(3, threeMonitorLayout);
// S.def(2, twoMonitorLayout);
S.def(1, oneMonitorLayout);

// Layout Operations
var threeMonitor = S.op("layout", { name: threeMonitorLayout });
// var twoMonitor = S.op('layout', { name: twoMonitorLayout });
var oneMonitor = S.op("layout", { name: oneMonitorLayout });
var devZen = S.op("layout", { name: devZenLayout });

var universalLayout = function () {
  // Should probably make sure the resolutions match but w/e
  S.log("SCREEN COUNT: " + S.screenCount());
  if (S.screenCount() === 3) {
    threeMonitor.run();
  } else if (S.screenCount() === 1) {
    oneMonitor.run();
  }
  // } else if (S.screenCount() === 2) {
  //   twoMonitor.run();
  // } else if (S.screenCount() === 1) {
  //   oneMonitor.run();
  // }
};

var zenLayout = function () {
  devZen.run();
};

// Batch bind everything. Less typing.
S.bnda({
  // Layout Bindings
  "1:ctrl;cmd": universalLayout,
  "2:ctrl;cmd": zenLayout,

  // Basic Location Bindings
  "pad0:ctrl": lapChat,
  "[:ctrl": tboltLeftHalf,
  "pad.:ctrl": lapMain,
  "]:ctrl": tboltRightHalf,
  "pad1:ctrl": tboltLeftBot,
  "pad2:ctrl": tboltMidBot,
  "pad3:ctrl": tboltRightBot,
  "pad4:ctrl": tboltLeftTop,
  "pad5:ctrl": tboltMidTop,
  "pad6:ctrl": tboltRightTop,
  "pad7:ctrl": tboltLeft,
  "pad8:ctrl": tboltMid,
  "pad9:ctrl": tboltRight,
  "pad=:ctrl": tboltFull,
  "return:ctrl;shift": tboltFull,

  // Resize Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  "right:ctrl;shift;cmd": S.op("resize", { width: "+10%", height: "+0" }),
  "left:ctrl;shift;cmd": S.op("resize", { width: "-10%", height: "+0" }),
  "up:ctrl": S.op("resize", { width: "+0", height: "-10%" }),
  "down:ctrl": S.op("resize", { width: "+0", height: "+10%" }),
  "pad+:ctrl": S.op("resize", {
    width: "-10%",
    height: "+0",
    anchor: "bottom-right",
  }),
  "pad-:ctrl": S.op("resize", {
    width: "+10%",
    height: "+0",
    anchor: "bottom-right",
  }),
  // 'up:alt': S.op('resize', {
  //   width: '+0',
  //   height: '+10%',
  //   anchor: 'bottom-right',
  // }),
  // 'down:alt': S.op('resize', {
  //   width: '+0',
  //   height: '-10%',
  //   anchor: 'bottom-right',
  // }),

  // Push Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  "right:ctrl;shift": S.op("push", {
    direction: "right",
    style: "bar-resize:screenSizeX/2",
  }),
  "left:ctrl;shift": S.op("push", {
    direction: "left",
    style: "bar-resize:screenSizeX/2",
  }),
  "up:ctrl;shift": S.op("push", {
    direction: "up",
    style: "bar-resize:screenSizeY/2",
  }),
  "down:ctrl;shift": S.op("push", {
    direction: "down",
    style: "bar-resize:screenSizeY/2",
  }),

  // Nudge Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  // 'right:ctrl;alt': S.op('nudge', { x: '+10%', y: '+0' }),
  // 'left:ctrl;alt': S.op('nudge', { x: '-10%', y: '+0' }),
  // 'up:ctrl;alt': S.op('nudge', { x: '+0', y: '-10%' }),
  // 'down:ctrl;alt': S.op('nudge', { x: '+0', y: '+10%' }),

  // Throw Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  "pad1:ctrl;alt": S.op("throw", {
    screen: "0",
    width: "screenSizeX",
    height: "screenSizeY",
  }),
  "pad2:ctrl;alt": S.op("throw", {
    screen: "1",
    width: "screenSizeX",
    height: "screenSizeY",
  }),
  "pad3:ctrl;alt": S.op("throw", {
    screen: "2",
    width: "screenSizeX",
    height: "screenSizeY",
  }),
  "right:ctrl;alt;cmd": S.op("throw", {
    screen: "right",
    width: "screenSizeX",
    height: "screenSizeY",
  }),
  "left:ctrl;alt;cmd": S.op("throw", {
    screen: "left",
    width: "screenSizeX",
    height: "screenSizeY",
  }),
  "up:ctrl;alt;cmd": S.op("throw", {
    screen: "up",
    width: "screenSizeX",
    height: "screenSizeY",
  }),
  "down:ctrl;alt;cmd": S.op("throw", {
    screen: "down",
    width: "screenSizeX",
    height: "screenSizeY",
  }),

  // Focus Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  // 'l:cmd': S.op('focus', { direction: 'right' }),
  // 'h:cmd': S.op('focus', { direction: 'left' }),
  // 'k:cmd': S.op('focus', { direction: 'up' }),
  // 'j:cmd': S.op('focus', { direction: 'down' }),
  // 'k:cmd;alt': S.op('focus', { direction: 'behind' }),
  // 'j:cmd;alt': S.op('focus', { direction: 'behind' }),
  // 'right:cmd': S.op('focus', { direction: 'right' }),
  // 'left:cmd': S.op('focus', { direction: 'left' }),
  // 'up:cmd': S.op('focus', { direction: 'up' }),
  // 'down:cmd': S.op('focus', { direction: 'down' }),
  // 'up:cmd;alt': S.op('focus', { direction: 'behind' }),
  // 'down:cmd;alt': S.op('focus', { direction: 'behind' }),

  // Window Hints
  "esc:cmd": S.op("hint"),

  // Switch currently doesn't work well so I'm commenting it out until I fix it.
  //"tab:cmd" : S.op("switch"),

  // Grid
  "esc:ctrl": S.op("grid"),
});

// Test Cases
S.src(".slate.test", true);
S.src(".slate.test.js", true);

// Log that we're done configuring
S.log("[SLATE] -------------- Finished Loading Config --------------");
