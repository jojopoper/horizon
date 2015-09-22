package test

import (
	"github.com/Sirupsen/logrus"
	"github.com/jojopoper/horizon/log"
)

var testLogger *logrus.Entry

func init() {
	testLogger, _ = log.New()
	testLogger.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
	testLogger.Logger.Level = logrus.DebugLevel
}
