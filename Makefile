include .env
export

help: .help-base .help-build

include .make/st.mk
include .make/base.mk
