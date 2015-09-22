package db

import (
	"database/sql"
	sq "github.com/lann/squirrel"
	"time"
)

// Provides a squirrel.SelectBuilder upon which you may build actual queries.
var TransactionRecordSelect sq.SelectBuilder = sq.
	Select("ht.*, hl.closed_at AS ledger_close_time").
	From("history_transactions ht").
	LeftJoin("history_ledgers hl ON ht.ledger_sequence = hl.sequence")

type TransactionRecord struct {
	HistoryRecord
	TransactionHash     string         `db:"transaction_hash"`
	LedgerSequence      int32          `db:"ledger_sequence"`
	LedgerCloseTime     time.Time      `db:"ledger_close_time"`
	ApplicationOrder    int32          `db:"application_order"`
	Account             string         `db:"account"`
	AccountSequence     int64          `db:"account_sequence"`
	MaxFee              int32          `db:"max_fee"`
	FeePaid             int32          `db:"fee_paid"`
	OperationCount      int32          `db:"operation_count"`
	TransactionStatusId int32          `db:"transaction_status_id"`
	TxEnvelope          sql.NullString `db:"tx_envelope"`
	TxResult            sql.NullString `db:"tx_result"`
	TxMeta              sql.NullString `db:"tx_meta"`
	CreatedAt           time.Time      `db:"created_at"`
	UpdatedAt           time.Time      `db:"updated_at"`
}

func (r TransactionRecord) TableName() string {
	return "history_transactions"
}
