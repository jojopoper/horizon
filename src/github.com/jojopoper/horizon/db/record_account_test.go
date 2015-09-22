package db

import (
	"testing"

	."github.com/smartystreets/goconvey/convey"

)

func TestAccountRecord(t *testing.T) {

    Convey("Should be able to set the Id of LegderRecord", t, func() {
        record := new(AccountRecord)
        record.Id = 5
        So(record.Id, ShouldEqual, 5)
        Convey("PagingToken() returns an id ", func() {
            So(record.PagingToken(), ShouldEqual, "5")
		    })
	    })
}