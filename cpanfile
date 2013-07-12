requires 'perl', '5.008001';
requires 'Math::Matrix', '0.7';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Text::CSV', '1.32';
};

