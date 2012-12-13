// Copyright (c) 2011 Motorola Mobility, Inc. All rights reserved.
//
// This program is confidential and proprietary to Motorola Mobility, Inc and
// may not be copied, reproduced, disclosed to others, published or used, in
// whole or in part, without the expressed prior written permission of Motorola
// Mobility, Inc.

#include "TApplication.h"

#include "debug/TTracker.h"
#include "debug/TLogTracker.h"
#include "directfb.h"

#include <cstdlib>

TTracker* ProcessTracker = NULL;

TTracker* TTracker::GetProcessTracker()
{
  if (ProcessTracker == NULL) {
    ProcessTracker = new TLogTracker;
  }
  return ProcessTracker;
}

int main(int argc, char** argv)
{
  // DirectFB initialization
  DirectFBInit(&argc, &argv);

  TApplication application;
  application.Run();

  return EXIT_SUCCESS;
}
