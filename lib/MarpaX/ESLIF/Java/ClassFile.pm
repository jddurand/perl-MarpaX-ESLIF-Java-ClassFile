package MarpaX::ESLIF::Java::ClassFile;
use Config;
use Class::Tiny qw/source to logger/;
use Log::Any qw/$log/;
use Log::Any::Adapter;
use Log::Any::Adapter::Stderr;
use MarpaX::ESLIF;

Log::Any::Adapter->set('Stderr');

our $DATA = do {
    local $/;
    my $data = <DATA>;
    my $be = defined($Config::Config{byteorder}) && ($Config::Config{byteorder} eq '4321');
    #
    # For performance we want to know in advance if we have
    # to do network-to-host byte translation
    #
    $data =~ s/pause => before name => u/# pause => before name => u/g if $BE;
    $data
};

sub BUILD {
    my ($self, $args) = @_;

    my $logger = $self->logger;
    $self->logger($logger = $log) unless $logger;

    my $eslif = MarpaX::ESLIF->new($logger);
    my $grammar = MarpaX::ESLIF::Grammar->new($eslif, $DATA);
}

#
# ClassFile {
#     u4             magic;
#     u2             minor_version;
#     u2             major_version;
#     u2             constant_pool_count;
#     cp_info        constant_pool[constant_pool_count-1];
#     u2             access_flags;
#     u2             this_class;
#     u2             super_class;
#     u2             interfaces_count;
#     u2             interfaces[interfaces_count];
#     u2             fields_count;
#     field_info     fields[fields_count];
#     u2             methods_count;
#     method_info    methods[methods_count];
#     u2             attributes_count;
#     attribute_info attributes[attributes_count];
# }
# 
sub unpack_ClassFile {
    my ($buffer) = @_;

    my ($magic, $minor_version, $major_version, $constant_pool_count) = unpack('Nnnn', $buffer);
    
}

1;

__DATA__
#
# Reference: https://docs.oracle.com/javase/specs/jvms/se9/html/jvms-4.html
#
:start ::= ClassFile

U1 ~ 'dummy'
U2 ~ 'dummy'
U4 ~ 'dummy'

event ^u1 = predicted u1
event ^u2 = predicted u2
event ^u4 = predicted u4
u1 ::= U1
u2 ::= U2
u4 ::= U4

ClassFile ::=
    u4             # magic;
    u2             # minor_version;
    u2             # major_version;
    u2             # constant_pool_count;
    cp_info        # constant_pool[constant_pool_count-1];
    u2             # access_flags;
    u2             # this_class;
    u2             # super_class;
    u2             # interfaces_count;
    u2             # interfaces[interfaces_count];
    u2             # fields_count;
    field_info     # fields[fields_count];
    u2             # methods_count;
    method_info    # methods[methods_count];
    u2             # attributes_count;
    attribute_info # attributes[attributes_count];
action => ClassFile

cp_info ::=
    u1 # tag
    u1 # info
action => cp_info

field_info ::=
    u2             # access_flags;
    u2             # name_index;
    u2             # descriptor_index;
    u2             # attributes_count;
    attribute_info # attributes[attributes_count];
action => field_info

method_info ::=
    u2             # access_flags;
    u2             # name_index;
    u2             # descriptor_index;
    u2             # attributes_count;
    attribute_info # attributes[attributes_count];
action => method_info

attribute_info ::=
    u2 # attribute_name_index;
    u4 # attribute_length;
    u1 # info[attribute_length];
action => attribute_info
