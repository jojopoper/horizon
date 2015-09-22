package db

import (
	"github.com/jojopoper/go-stellar-base/xdr" // fixup "github.com/stellar/go-stellar-base/xdr" to "github.com/jojopoper/go-stellar-base/xdr"
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

const (
	// PaymentTypeFilter restricts an OperationPageQuery to return only
	// Payment and PathPayment operations
	PaymentTypeFilter = "payment"
)

var operationFilterMap = map[string][]xdr.OperationType{
	PaymentTypeFilter: []xdr.OperationType{
		xdr.OperationTypeCreateAccount,
		xdr.OperationTypePayment,
		xdr.OperationTypePathPayment,
	},
}

// OperationPageQuery is the main query for paging through a collection
// of operations in the history database.
type OperationPageQuery struct {
	SqlQuery
	PageQuery
	AccountAddress  string
	LedgerSequence  int32
	TransactionHash string
	TypeFilter      string
}

// Select executes the query and returns the results
func (q OperationPageQuery) Select(ctx context.Context, dest interface{}) error {
	sql := OperationRecordSelect.
		Limit(uint64(q.Limit)).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB)

	cursor, err := q.CursorInt64()
	if err != nil {
		return err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("hop.id > ?", cursor).OrderBy("hop.id asc")
	case "desc":
		sql = sql.Where("hop.id < ?", cursor).OrderBy("hop.id desc")
	}

	err = checkOptions(
		q.AccountAddress != "",
		q.LedgerSequence != 0,
		q.TransactionHash != "",
	)

	if err != nil {
		return err
	}

	// filter by ledger sequence
	if q.LedgerSequence != 0 {
		var ledger LedgerRecord
		err := Get(ctx, LedgerBySequenceQuery{q.SqlQuery, q.LedgerSequence}, &ledger)

		if err != nil {
			return err
		}
		start := TotalOrderId{LedgerSequence: q.LedgerSequence}
		end := TotalOrderId{LedgerSequence: q.LedgerSequence + 1}
		sql = sql.Where("hop.id >= ? AND hop.id < ?", start.ToInt64(), end.ToInt64())
	}

	// filter by transaction hash
	if q.TransactionHash != "" {
		var tx TransactionRecord
		err := Get(ctx, TransactionByHashQuery{q.SqlQuery, q.TransactionHash}, &tx)

		if err != nil {
			return err
		}

		start := ParseTotalOrderId(tx.Id)
		end := start
		end.TransactionOrder++
		sql = sql.Where("hop.id >= ? AND hop.id < ?", start.ToInt64(), end.ToInt64())
	}

	// filter by account address
	if q.AccountAddress != "" {
		var account HistoryAccountRecord
		err := Get(ctx, HistoryAccountByAddressQuery{q.SqlQuery, q.AccountAddress}, &account)

		if err != nil {
			return err
		}

		sql = sql.
			Join("history_operation_participants hopp ON hopp.history_operation_id = hop.id").
			Where("hopp.history_account_id = ?", account.Id)
	}

	if types, ok := operationFilterMap[q.TypeFilter]; ok {
		sql = sql.Where(sq.Eq{"hop.type": types})
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
