#!/usr/bin/env bash

installed() {
    return "$(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')"
}