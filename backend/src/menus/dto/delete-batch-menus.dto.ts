import { IsArray, ArrayMinSize, ArrayMaxSize, IsInt } from 'class-validator';

export class DeleteBatchMenusDto {
  @IsArray()
  @ArrayMinSize(1, { message: 'At least one menu ID is required' })
  @ArrayMaxSize(100, { message: 'Maximum 100 menus per batch' })
  @IsInt({ each: true })
  ids: number[];
}
