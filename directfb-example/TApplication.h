// Copyright (c) 2011 Motorola Mobility, Inc. All rights reserved.
//
// This program is confidential and proprietary to Motorola Mobility, Inc and
// may not be copied, reproduced, disclosed to others, published or used, in
// whole or in part, without the expressed prior written permission of Motorola
// Mobility, Inc.

#ifndef TAPPLICATION_H
#define TAPPLICATION_H

#include "interface/IToiApplication.h"

#include "ipc/TIpcClient.h"
#include "ipc/TIpcServer.h"
#include "debug/TTracker.h"

#include "directfb.h"

class TToiNameServiceCaller;
class TToiApplicationServiceCaller;
class TToiApplicationDispatcher;

class TApplication : public IToiApplication,
                     public IIOEventHandler
{
private:
  TIpcClient IpcClient;
  TIpcServer IpcServer;

  TTracker* Tracker;

  int ApplicationId;

  TToiApplicationServiceCaller* ApplicationService;
  TToiApplicationDispatcher* ApplicationDispatcher;

  int ScreenWidth;
  int ScreenHeight;

  IDirectFB* Dfb;
  IDirectFBDisplayLayer* Layer;
  IDirectFBWindow* Window;
  IDirectFBSurface* Surface;
  IDirectFBFont* Font;
  IDirectFBEventBuffer* InputEventBuffer;

  int DfbInputFd;

  void RegisterApplication(TToiNameServiceCaller& nameService);
  void InitDirectFb();

  void DrawHelloWorld();

  void OnKeyDown(int keycode, DFBInputDeviceModifierMask modifiers);
  void OnKeyUp(int keycode, DFBInputDeviceModifierMask modifiers);

 public:
  TApplication();
  virtual ~TApplication();

  void Run();

  // IToiApplication
  virtual void Ping() throw ();
  virtual void ChangeState(const IToiApplicationService::
                   TToiApplicationState& state) throw ();
  virtual void LoadUri(const std::string& uri,
               const std::string& mimeType) throw ();
  virtual void ExecuteCommand(const std::string& command) throw ();

  // IIOEventHandler
  virtual void HandleEvent(int fd, uint32_t event) throw ();
};

#endif
