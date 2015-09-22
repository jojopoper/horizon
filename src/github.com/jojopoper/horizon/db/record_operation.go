package db

import (
	"database/sql"
	"encoding/json"
	"github.com/jojopoper/go-stellar-base/xdr" // fixup "github.com/stellar/go-stellar-base/xdr" to "github.com/jojopoper/go-stellar-base/xdr"
	sq "github.com/lann/squirrel"
)

var OperationRecordSelect sq.SelectBuilder = sq.
	Select("hop.*").
	From("history_operations hop")

type OperationRecord struct {
	HistoryRecord
	TransactionId    int64             `db:"transaction_id"`
	ApplicationOrder int32             `db:"application_order"`
	Type             xdr.OperationType `db:"type"`
	DetailsString    sql.NullString    `db:"details"`
}

func (r OperationRecord) Details() (result map[string]interface{}, err error) {
	if !r.DetailsString.Valid {
		return
	}

	err = json.Unmarshal([]byte(r.DetailsString.String), &result)

	return
}
