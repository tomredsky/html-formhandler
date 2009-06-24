use strict;
use warnings;

use Test::More tests => 187;

#
# Boolean
#
my $class = 'HTML::FormHandler::Field::Boolean';
use_ok($class);
my $field = $class->new( name => 'test_field', );
ok( defined $field, 'new() called' );
$field->input(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test true == 1' );
$field->input(0);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test true == 0' );
$field->input('checked');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 1, 'Test true == 1' );
$field->input('0');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 4' );
is( $field->value, 0, 'Test true == 0' );

# checkbox
$class = 'HTML::FormHandler::Field::Checkbox';
use_ok($class);
$field = $class->new( name => 'test_field', );
ok( defined $field, 'new() called' );
$field->input(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'input 1 is 1' );
$field->input(0);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'input 0 is 0' );
$field->input('checked');
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'checked', 'value is "checked"' );
$field->input(undef);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 4' );
is( $field->value, 0, 'input undef is 0' );
$field = $class->new(
   name     => 'test_field2',
   required => 1
);
$field->input(0);
$field->validate_field;
ok( $field->has_errors, 'required field fails with 0' );

# datetime
SKIP:
{
   eval { require DBIx::Class; require DateTime; };
   skip "DBIx::Class required", 3 if $@;
   use lib './t';
   use lib 't/lib';
   use BookDB::Schema::DB;
   use_ok('HTML::FormHandler::Field::DateTime');
   my $field = HTML::FormHandler::Field::DateTime->new( name => 'test_field' );
   ok( defined $field, 'new() called' );

   {

      package UserForm;

      use HTML::FormHandler::Moose;
      extends 'HTML::FormHandler::Model::DBIC';
      with 'HTML::FormHandler::Render::Simple';

      has_field 'birthdate'      => ( type => 'DateTime' );
      has_field 'birthdate.year' => ( type => 'Year' );
   }

   my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
   my $user = $schema->resultset('User')->first;
   my $form = UserForm->new( item => $user );
   ok( $form, 'Form with DateTime field loaded from the db' );
}

# email
#
#
SKIP:
{
   eval { require Email::Valid };
   skip "Email::Valid required", 5 if $@;

   my $class = 'HTML::FormHandler::Field::Email';
   use_ok($class);
   my $field = $class->new( name => 'test_field',); 
   ok( defined $field, 'new() called' );

   $field->input('foo@bar.com');
   $field->validate_field;
   ok( !$field->has_errors, 'Test for errors 1' );
   is( $field->value, 'foo@bar.com', 'value returned' );

   $field->input('foo@bar');
   $field->validate_field;
   ok( $field->has_errors, 'Test for errors 1' );
   is(
      $field->errors->[0],
      'Email should be of the format someuser@example.com',
      'Test error message'
   );

   $field->input('someuser@example.com');
   $field->validate_field;
   ok( !$field->has_errors, 'Test for errors 2' );

}

# hidden

$class = 'HTML::FormHandler::Field::Hidden';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
my $string = 'Some text';
$field->input( $string );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $string, 'is value input string');
$field->input( '' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, undef, 'is value input string');
$field->required(1);
$field->validate_field;
ok( $field->has_errors, 'Test for errors 3' );
$field->input('hello');
$field->required(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'hello', 'Check again' );
$field->size( 3 );
$field->validate_field;
ok( $field->has_errors, 'Test for too long' );
$field->size( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test for right length' );
$field->min_length( 10 );
$field->validate_field;
ok( $field->has_errors, 'Test not long enough' );
$field->min_length( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test just long enough' );
$field->min_length( 4 );
$field->validate_field;
ok( !$field->has_errors, 'Test plenty long enough' );

# integer

$class = 'HTML::FormHandler::Field::Integer';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test value == 1' );
$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test value == 0' );
$field->input( 'checked' );
$field->validate_field;
ok( $field->has_errors, 'Test non integer' );
$field->input( '+10' );
$field->validate_field;
ok( !$field->has_errors, 'Test positive' );
is( $field->value, 10, 'Test value == 10' );
$field->input( '-10' );
$field->validate_field;
ok( !$field->has_errors, 'Test negative' );
is( $field->value, -10, 'Test value == -10' );
$field->input( '-10.123' );
$field->validate_field;
ok( $field->has_errors, 'Test real number' );
$field->range_start( 10 );
$field->input( 9 );
$field->validate_field;
ok( $field->has_errors, 'Test 9 < 10 fails' );
$field->input( 100 );
$field->validate_field;
ok( !$field->has_errors, 'Test 100 > 10 passes ' );
$field->range_end( 20 );
$field->input( 100 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 100 <= 20 fails' );
$field->range_end( 20 );
$field->input( 15 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 15 <= 20 passes' );
$field->input( 10 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 10 <= 20 passes' );
$field->input( 20 );
$field->validate_field;
ok( !$field->has_errors, 'Test 10 <= 20 <= 20 passes' );
$field->input( 21 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 21 <= 20 fails' );
$field->input( 9 );
$field->validate_field;
ok( $field->has_errors, 'Test 10 <= 9 <= 20 fails' );


# intrange.t

$class = 'HTML::FormHandler::Field::IntRange';
use_ok( $class );
$field = $class->new(
    name    => 'test_field',
    range_start => 30,
    range_end   => 39,
);
ok( defined $field,  'new() called' );
$field->input( 30 );
$field->validate_field;
ok( !$field->has_errors, '30 in range' );
$field->input( 39 );
$field->validate_field;
ok( !$field->has_errors, '39 in range' );
$field->input( 35 );
$field->validate_field;
ok( !$field->has_errors, '35 in range' );
$field->input( 29 );
$field->validate_field;
ok( $field->has_errors, '29 out of range' );
$field->input( 40 );
$field->validate_field;
ok( $field->has_errors, '40 out of range' );

# minute

$class = 'HTML::FormHandler::Field::Minute';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, '0 in range' );
$field->input( 59 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );
$field->input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );
$field->input( -1  );
$field->validate_field;
ok( $field->has_errors, '-1 out of range' );
$field->input( 60 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );

# money

$class = 'HTML::FormHandler::Field::Money';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( '   $123.45  ' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors "   $123.00  "' );
is( $field->value, 123.45, 'Test value == 123.45' );
$field->input( '   $12x3.45  ' );
$field->validate_field;
ok( $field->has_errors, 'Test for errors "   $12x3.45  "' );
is( $field->errors->[0], 'Value cannot be converted to money', 'get error' );
$field->input( 2345 );
$field->validate_field;
is( $field->value, '2345.00', 'transformation worked: 2345 => 2345.00' );


# monthday

$class = 'HTML::FormHandler::Field::MonthDay';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, '1 in range' );
$field->input( 31 );
$field->validate_field;
ok( !$field->has_errors, '31 in range' );
$field->input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );
$field->input( 0  );
$field->validate_field;
ok( $field->has_errors, '0 out of range' );
$field->input( 32 );
$field->validate_field;
ok( $field->has_errors, '32 out of range' );

# monthname

$class = 'HTML::FormHandler::Field::MonthName';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
for ( 1 .. 12 ) {
    $field->input( $_ );
    $field->validate_field;
    ok( !$field->has_errors, $_ . ' is valid' );
}
$field->input( 0 );
$field->validate_field;
ok( $field->has_errors, '0 is not valid day of the week' );
$field->input( 13 );
$field->validate_field;
ok( $field->has_errors, '13 is not valid day of the week' );

#month

$class = 'HTML::FormHandler::Field::Month';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, '1 in range' );
$field->input( 12 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );
$field->input( 6 );
$field->validate_field;
ok( !$field->has_errors, '6 in range' );
$field->input( 0  );
$field->validate_field;
ok( $field->has_errors, '0 out of range' );
$field->input( 13 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );
$field->input( 'March' );
$field->validate_field;
ok( $field->has_errors, 'March is not numeric' );
is( $field->errors->[0], "'March' is not a valid value", 'is error message' );


# multiple

$class = 'HTML::FormHandler::Field::Multiple';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
$field->options([
    { value => 1, label => 'one' },
    { value => 2, label => 'two' },
    { value => 3, label => 'three' },
]);
ok( defined $field,  'new() called' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is_deeply( $field->value, [1], 'Test 1 => [1]' );
$field->input( [1] );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
ok( eq_array( $field->value, [1], 'test array' ), 'Check [1]');
$field->input( [1,2] );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
ok( eq_array( $field->value, [1,2], 'test array' ), 'Check [1,2]');
$field->input( [1,2,4] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors 4' );
is( $field->errors->[0], "'4' is not a valid value", 'Error message' );

# password tested separately. requires a form.

# posinteger

$class = 'HTML::FormHandler::Field::PosInteger';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test value == 1' );
$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, 0, 'Test value == 0' );
$field->input( 'checked' );
$field->validate_field;
ok( $field->has_errors, 'Test non integer' );
$field->input( '+10' );
$field->validate_field;
ok( !$field->has_errors, 'Test positive' );
is( $field->value, 10, 'Test value == 10' );
$field->input( '-10' );
$field->validate_field;
ok( $field->has_errors, 'Test negative' );
$field->input( '-10.123' );
$field->validate_field;
ok( $field->has_errors, 'Test real number ' );

# second

$class = 'HTML::FormHandler::Field::Second';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$field->input( 0 );
$field->validate_field;
ok( !$field->has_errors, '0 in range' );
$field->input( 59 );
$field->validate_field;
ok( !$field->has_errors, '59 in range' );
$field->input( 12 );
$field->validate_field;
ok( !$field->has_errors, '12 in range' );
$field->input( -1  );
$field->validate_field;
ok( $field->has_errors, '-1 out of range' );
$field->input( 60 );
$field->validate_field;
ok( $field->has_errors, '60 out of range' );

# select

$class = 'HTML::FormHandler::Field::Select';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( $field->options, 'Test for init_options failure in 0.09' );
$field->options([
    { value => 1, label => 'one' },
    { value => 2, label => 'two' },
    { value => 3, label => 'three' },
]);
ok( defined $field,  'new() called' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test true == 1' );
$field->input( [1] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors array' );
$field->input( [1,4] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors 4' );
is( $field->errors->[0], 'This field does not take multiple values', 'Error message' );

# textarea

$class = 'HTML::FormHandler::Field::TextArea';
use_ok( $class );
$field = $class->new( name => 'comments', cols => 40, rows => 3 );
ok( $field, 'get TextArea field');
$field->input("Testing, testing, testing... This is a test");
$field->validate_field;
ok( !$field->has_errors, 'field has no errors');

# text

$class = 'HTML::FormHandler::Field::Text';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
$string = 'Some text';
$field->input( $string );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, $string, 'is value input string');
$field->input( '' );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 2' );
is( $field->value, undef, 'is value input string');
$field->required(1);
$field->validate_field;
ok( $field->has_errors, 'Test for errors 3' );
$field->input('hello');
$field->required(1);
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 3' );
is( $field->value, 'hello', 'Check again' );
$field->size( 3 );
$field->validate_field;
ok( $field->has_errors, 'Test for too long' );
$field->size( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test for right length' );
$field->min_length( 10 );
$field->validate_field;
ok( $field->has_errors, 'Test not long enough' );
$field->min_length( 5 );
$field->validate_field;
ok( !$field->has_errors, 'Test just long enough' );
$field->min_length( 4 );
$field->validate_field;
ok( !$field->has_errors, 'Test plenty long enough' );

# weekday

$class = 'HTML::FormHandler::Field::Weekday';
use_ok( $class );
$field = $class->new( name    => 'test_field',);
ok( defined $field,  'new() called' );
for ( 0 .. 6 ) {
    $field->input( $_ );
    $field->validate_field;
    ok( !$field->has_errors, $_ . ' is valid' );
}
$field->input( -1 );
$field->validate_field;
ok( $field->has_errors, '-1 is not valid day of the week' );
$field->input( 7 );
$field->validate_field;
ok( $field->has_errors, '7 is not valid day of the week' );

# year

$class = 'HTML::FormHandler::Field::Year';
use_ok( $class );
$field = $class->new( name    => 'test_field' );
ok( defined $field,  'new() called' );
$field->input( 0 );
$field->validate_field;
ok( $field->has_errors, '0 is bad year' );
$field->input( (localtime)[5] + 1900 );
$field->validate_field;
ok ( !$field->has_errors, 'Now is just a fine year' );
$field->input( 2100 );
$field->validate_field;
ok( $field->has_errors, '2100 makes the author really old' );



