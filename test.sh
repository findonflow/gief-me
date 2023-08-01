#!/bin/bash

set -e

flow test --cover $(find ./cadence/tests -name '*.t.cdc')