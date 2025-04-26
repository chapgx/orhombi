package rhombi


Flag :: struct {
	Name:     string,
	Short:    string,
	Desc:     string,
	LongDesc: string,
	Required: bool,
	Single:   bool, // uses a single value
	Values:   [dynamic]string,
}
