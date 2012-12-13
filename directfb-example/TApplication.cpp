// Copyright (c) 2011 Motorola Mobility, Inc. All rights reserved.
//
// This program is confidential and proprietary to Motorola Mobility, Inc and
// may not be copied, reproduced, disclosed to others, published or used, in
// whole or in part, without the expressed prior written permission of Motorola
// Mobility, Inc.

#include "TApplication.h"

#include "interface/ToiObjectNames.h"
#include "interface/TToiNameServiceCaller.h"
#include "interface/TToiApplicationServiceCaller.h"
#include "interface/TToiApplicationDispatcher.h"

#define DFBCHECK(x...)                                                    \
     {                                                                    \
          DFBResult err = x;                                              \
          if (err != DFB_OK) {                                            \
               Tracker->Error("DirectFB error in %s", __func__);          \
               DirectFBErrorFatal( #x, err );                             \
          }                                                               \
     }

void TApplication::RegisterApplication(TToiNameServiceCaller& nameService)
{
  // Get application ID
  char* id = ::getenv("APPLICATION_ID");
  if (id == NULL) {
    throw TException("APPLICATION_ID not set.");
  }
  char* endPtr;
  ApplicationId = strtol(id, &endPtr, 10);
  if (id[0] == '\0' || endPtr[0] != '\0') {
    throw TException("APPLICATION_ID string has illegal format");
  }

  // Connect to the application service.
  std::string appServiceAddress;
  nameService.LookupObject(TOI_APPLICATION_SERVICE_NAME, appServiceAddress);
  ApplicationService = new TToiApplicationServiceCaller(&IpcClient,
                                                        appServiceAddress);

  std::string applicationAddress = IpcServer.CreateObject();
  ApplicationDispatcher = new TToiApplicationDispatcher(&IpcServer,
                                                        applicationAddress,
                                                        this);

  ApplicationService->ReportStarted(ApplicationId, applicationAddress);
}

void TApplication::InitDirectFb()
{
  DFBCHECK(DirectFBCreate(&Dfb));

  DFBCHECK(Dfb->SetCooperativeLevel(Dfb, DFSCL_NORMAL));

  // Handle DirectFB input events in the IpcServer's event loop
  DFBCHECK(Dfb->CreateInputEventBuffer(
             Dfb,
             DFBInputDeviceCapabilities(DICAPS_BUTTONS | DICAPS_KEYS),
             DFB_TRUE,
             &InputEventBuffer));

  DFBCHECK(InputEventBuffer->CreateFileDescriptor(InputEventBuffer,
                                                  &DfbInputFd));
  IpcServer.GetEventLoop()->AddDescriptor(DfbInputFd,
                                          IIOEventLoop::EVENT_READ,
                                          IIOEventLoop::PRIORITY_NORMAL,
                                          this);

  // Layer
  DFBCHECK(Dfb->GetDisplayLayer(Dfb, DLID_PRIMARY, &Layer));

  // Window
  DFBWindowDescription desc;
  desc.flags = DFBWindowDescriptionFlags(DWDESC_POSX
                                         | DWDESC_POSY
                                         | DWDESC_WIDTH
                                         | DWDESC_HEIGHT
                                         | DWDESC_SURFACE_CAPS);
  desc.posx = 0;
  desc.posy = 0;
  desc.width = ScreenWidth;
  desc.height = ScreenHeight;
  desc.surface_caps = DSCAPS_FLIPPING;
  DFBCHECK(Layer->CreateWindow(Layer, &desc, &Window));
  DFBCHECK(Window->SetOpacity(Window, 255));

  // Surface
  DFBCHECK(Window->GetSurface(Window, &Surface));

  // Use the Krea font
  DFBFontDescription fontDsc;
  fontDsc.flags = DFDESC_HEIGHT;
  fontDsc.height = 60;
  DFBCHECK(Dfb->CreateFont(Dfb, "/usr/share/fonts/KREAB.TTF",
                           &fontDsc,
                           &Font));
}

void TApplication::DrawHelloWorld()
{
  DFBCHECK(Surface->Clear(Surface, 255, 255, 255, 255));
  DFBCHECK(Surface->SetFont(Surface, Font));
  DFBCHECK(Surface->SetColor(Surface, 0, 0, 0, 255));

  DFBCHECK(Surface->DrawString(Surface,
                               "Hello World!",
                               -1,
                               640,
                               360,
                               DSTF_CENTER));

  DFBCHECK(Surface->Flip(Surface, 0, DSFLIP_NONE));
}

TApplication::TApplication()
  : Tracker(TTracker::GetProcessTracker()),
    ApplicationService(NULL),
    ApplicationDispatcher(NULL),
    ScreenWidth(1280),
    ScreenHeight(720),
    Dfb(NULL),
    Layer(NULL),
    Window(NULL),
    Surface(NULL),
    Font(NULL),
    InputEventBuffer(NULL),
    DfbInputFd(-1)
{
  // Connect to nameservice.
  char* address = ::getenv("NAMESERVICE_ADDRESS");
  if (address == NULL) {
    throw TException("NAMESERVICE_ADDRESS not set.");
  }
  TToiNameServiceCaller nameService(&IpcClient, address);

  RegisterApplication(nameService);
  InitDirectFb();

  DrawHelloWorld();
}

TApplication::~TApplication()
{
  Dfb->Release(Dfb);
  delete ApplicationService;
  delete ApplicationDispatcher;
}

void TApplication::Run()
{
  IpcServer.Run();
}

void TApplication::OnKeyDown(int keycode,
                             DFBInputDeviceModifierMask /*modifiers*/)
{
  if (keycode == 0x67) { // Up
    Tracker->Note("Up");
  }
  else if (keycode == 0x6C) { // Down
    Tracker->Note("Down");
  }
}

void TApplication::OnKeyUp(int /*keycode*/,
                           DFBInputDeviceModifierMask /*modifiers*/)
{
  // Empty
}

// IToiApplication
void TApplication::Ping() throw ()
{
  ApplicationService->ReportPing(ApplicationId);
}

void TApplication::ChangeState(const IToiApplicationService::
                               TToiApplicationState& /*state*/) throw ()
{
  // Empty
}

void TApplication::LoadUri(const std::string& /*uri*/,
                           const std::string& /*mimeType*/) throw ()
{
  // Empty
}

void TApplication::ExecuteCommand(const std::string& /*command*/) throw ()
{
  // Empty
}

void TApplication::HandleEvent(int fd, uint32_t /*event*/) throw ()
{
  if (fd == DfbInputFd) {
    DFBEvent dfbEvent;

    for (;;) {
      char* buffer = reinterpret_cast<char*>(&dfbEvent);
      int readSize = ::read(fd, buffer, sizeof(DFBEvent));
      if (readSize == -1) {
        if (errno == EINTR) {
          continue;
        }
        return;
      }

      // Some kind of sanity check...
      if (readSize < (int) sizeof(DFBEvent)) {
        Tracker->Debug("%s: Read less than the size of DFBEvent", __func__);
        return;
      }

      break;
    }

    if (dfbEvent.clazz == DFEC_INPUT) {
      if (dfbEvent.input.type == DIET_KEYPRESS) {
        OnKeyDown(dfbEvent.input.key_code, dfbEvent.input.modifiers);
      }
      else if (dfbEvent.input.type == DIET_KEYRELEASE) {
        OnKeyUp(dfbEvent.input.key_code, dfbEvent.input.modifiers);
      }
    }
  }
}
