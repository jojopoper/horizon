package db

import (
	"database/sql"
	"errors"
	"fmt"
	"os"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/jojopoper/horizon/test"
	"golang.org/x/net/context"
)

var ctx context.Context
var core *sql.DB
var history *sql.DB

func TestMain(m *testing.M) {
	ctx = test.Context()
	core = OpenStellarCoreTestDatabase()
	history = OpenTestDatabase()
	defer core.Close()
	defer history.Close()

	os.Exit(m.Run())

}

func TestDBOpen(t *testing.T) {
	Convey("db.Open", t, func() {
		// TODO
	})
}

func TestDBPackage(t *testing.T) {
	test.LoadScenario("non_native_payment")

	Convey("db.Select", t, func() {
		Convey("overwrites the destination", func() {
			records := []mockResult{{1}, {2}}
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldBeNil)
			So(len(records), ShouldEqual, 5)
		})

		Convey("works on []interface{} destinations", func() {
			var records []mockResult
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldBeNil)
			So(len(records), ShouldEqual, 5)
		})

		Convey("returns an error when the provided destination is nil", func() {
			query := &mockQuery{5}
			err := Select(ctx, query, nil)
			So(err, ShouldEqual, ErrDestinationNil)
		})

		Convey("returns an error when the provided destination is not a pointer", func() {
			var records []mockResult
			query := &mockQuery{5}
			err := Select(ctx, query, records)
			So(err, ShouldEqual, ErrDestinationNotPointer)
		})

		Convey("returns an error when the provided destination is not a slice", func() {
			var records string
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldEqual, ErrDestinationNotSlice)
		})

		Convey("returns an error when the provided destination is a slice of an invalid type", func() {
			var records []string
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldEqual, ErrDestinationIncompatible)
		})
	})

	Convey("db.Get", t, func() {
		var result mockResult

		Convey("returns the first record", func() {
			So(Get(ctx, &mockQuery{2}, &result), ShouldBeNil)
			So(result, ShouldResemble, mockResult{0})
		})

		Convey("Missing records returns nil", func() {
			So(Get(ctx, &mockQuery{0}, &result), ShouldEqual, ErrNoResults)
		})

		Convey("Properly forwards non-RecordNotFound errors", func() {
			query := &BrokenQuery{errors.New("Some error")}
			So(Get(ctx, query, &result).Error(), ShouldEqual, "Some error")
		})
	})
}

func ExampleGet() {
	db := OpenStellarCoreTestDatabase()
	defer db.Close()

	q := CoreAccountByAddressQuery{
		SqlQuery{db},
		"GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
	}

	var account CoreAccountRecord
	err := Get(context.Background(), q, &account)

	if err != nil {
		panic(err)
	}

	fmt.Printf("%s", account.Accountid)
	// Output: GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H
}

func ExampleSelect() {
	db := OpenStellarCoreTestDatabase()
	defer db.Close()

	q := CoreAccountByAddressQuery{
		SqlQuery{db},
		"GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
	}

	var records []CoreAccountRecord
	err := Select(context.Background(), q, &records)

	if err != nil {
		panic(err)
	}

	fmt.Printf("%d", len(records))
	// Output: 1
}
