package horizon

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/Sirupsen/logrus"
	gctx "github.com/goji/context"
	"github.com/jojopoper/horizon/log"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/mutil"
)

// LoggerMiddleware is the middleware that logs http requests and resposnes
// to the logging subsytem of horizon.
func LoggerMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)
		mw := mutil.WrapWriter(w)

		logStartOfRequest(ctx, r)

		then := time.Now()
		h.ServeHTTP(mw, r)
		duration := time.Now().Sub(then)

		logEndOfRequest(ctx, duration, mw)
	}

	return http.HandlerFunc(fn)
}

func logStartOfRequest(ctx context.Context, r *http.Request) {
	fields := logrus.Fields{
		"path":   r.URL.String(),
		"method": r.Method,
	}

	log.WithFields(ctx, fields).Info("Starting request")
}

func logEndOfRequest(ctx context.Context, duration time.Duration, mw mutil.WriterProxy) {
	fields := logrus.Fields{
		"status":   mw.Status(),
		"bytes":    mw.BytesWritten(),
		"duration": duration,
	}

	log.WithFields(ctx, fields).Info("Finished request")
}
