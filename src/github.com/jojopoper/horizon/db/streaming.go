package db

import (
	"database/sql"
	"time"

	"github.com/jojopoper/horizon/log"

	"golang.org/x/net/context"
)

// NewLedgerClosePump starts a background proc that continually watches the
// history database provided.  The watch is stopped after the provided context
// is cancelled.
//
// Every second, the proc spawned by calling this func will check to see
// if a new ledger has been imported (by ruby-horizon as of 2015-04-30, but
// should eventually end up being in this project).  If a new ledger is seen
// the the channel returned by this function emits
func NewLedgerClosePump(ctx context.Context, db *sql.DB) <-chan time.Time {
	result := make(chan time.Time)

	go func() {
		var lastSeenLedger int32
		for {
			select {
			case <-time.After(1 * time.Second):
				var latestLedger int32
				row := db.QueryRow("SELECT MAX(sequence) FROM history_ledgers")
				err := row.Scan(&latestLedger)

				if err != nil {
					log.Warn(ctx, "Failed to check latest ledger", err)
					break
				}

				if latestLedger > lastSeenLedger {
					log.Debugf(ctx, "saw new ledger: %d, prev: %d", latestLedger, lastSeenLedger)
					lastSeenLedger = latestLedger
					result <- time.Now()
				}

			case <-ctx.Done():
				log.Info(ctx, "canceling ledger pump")
				return
			}
		}
	}()

	return result
}
