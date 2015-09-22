package render

import (
	"net/http"

	"bitbucket.org/ww/goautoneg"
	"github.com/Sirupsen/logrus"
	"github.com/jojopoper/horizon/log"
	"golang.org/x/net/context"
)

// Negotiate inspects the Accept header of the provided request and determines
// what the most appropriate response type should be.  Defaults to HAL.
func Negotiate(ctx context.Context, r *http.Request) string {
	alternatives := []string{MimeHal, MimeJSON, MimeEventStream}
	accept := r.Header.Get("Accept")

	if accept == "" {
		return MimeHal
	}

	result := goautoneg.Negotiate(r.Header.Get("Accept"), alternatives)

	log.WithFields(ctx, logrus.Fields{
		"content_type": result,
		"accept":       accept,
	}).Debug("Negotiated content type")

	return result
}
